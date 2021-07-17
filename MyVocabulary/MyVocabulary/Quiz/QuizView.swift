//
//  QuizView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 21/3/21.
//

import SwiftUI
import AVFoundation

struct QuizView: View {
    
    /// The languages supported by the system to  read the translation input.
    private let languages: [SpeakingLanguage] = {
        AVSpeechSynthesisVoice.speechVoices().compactMap {
            if let language = Locale.current.localizedString(forLanguageCode: $0.language) {
                return SpeakingLanguage(voice: $0, language: "\(language) (\($0.language)) - \($0.name)")
            } else {
                return nil
            }
        }.sorted()
    }()
    
    @Binding private var appAction: AppAction?
    @Binding private var translations: [Translation]
    @StateObject private var viewModel: ViewModel
    @State private var languageIndex = 0
    
    @State private var isDisable: Bool = false
    
    // MARK: - Init
    
    init(
        translations: Binding<[Translation]>,
        appAction: Binding<AppAction?>,
        viewModel: ViewModel
    ) {
        self._translations = translations
        self._appAction = appAction
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
//                    Button(
//                            action: {
//                              isDisable = true
//                              withAnimation(
//                                .linear(duration: 1)
//                              ) {
//                                scale = scale - 0.1
//                                isDisable = false
//                              }
//                            },
//                            label: {
//                              Text("Tap Me")
//                            }
//                          )
//                          .disabled(
//                            isDisable
//                          )
                    
                    Button {
                        let duration: Double = 1
                        isDisable = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            isDisable = false
                        }
                        withAnimation(.linear(duration: duration)) {
                            scale -= 0.1
                        }
                    } label: {
                        Text("Tap Me")
                    }
                    
                    
                    if case .on(let questionIndex, let answerIndexes, _) = viewModel.status,
                       questionIndex < translations.count
                    {
                        let translation = translations[questionIndex]
                        levelSelector()
                        Spacer()
                        languageSelector(for: translation)
                            .padding([.bottom], 16)
                        translationAndLevel(for: translation)
                        testView(for: answerIndexes)
                        Spacer()
                        forwardButton()
                    } else {
                        PlaceholderView(
                            image: Image(systemName: "die.face.4"),
                            text: Text("You must have at least 4 translations to start the quiz.")
                        )
                        .navigationTitle("Quiz")
                    }
                }
            }
            .onChange(of: translations, perform: viewModel.updateStatus(_:))
            .onAppear(perform: handleOnAppear)
            .onChange(of: viewModel.status, perform: {
                guard case .on(let answer, _, let selected) = $0, selected != nil, answer != selected else { return }
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            })
            .onChange(of: appAction, perform: handleAppAction)
            .onDisappear(perform: viewModel.clearLevel)
        }
    }
}

// MARK: - Views

private extension QuizView {
    
    func translationAndLevel(for translation: Translation) -> some View {
        VStack(spacing: 16) {
            Text(translation.translationInput).font(.largeTitle).bold()
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.1)
            SegmentedProgressBar(level: translation.level).frame(height: 8)
        }
        .padding([.leading, .trailing, .bottom])
        .accessibilityElement()
        .accessibilityLabel("\(translation.translationInput). Level \(translation.level).")
    }
    
    func levelSelector() -> some View {
        HStack {
            ForEach(0...Int(Translation.maxLevel), id: \.self) { level in
                Button("\(level)") {
                    viewModel.changeLevel(to: level, with: translations)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .disabled(viewModel.notAvailableTranslations(of: level))
                .accentColor(Color("Light Blue"))
                .overlay(Circle().stroke(Color("Dark Blue"), lineWidth: strokeWidth(for: level)))
                .minimumScaleFactor(0.5)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabelForLevelButton(with: level))
            }
        }
        .padding()
    }
    
    func languageSelector(for translation: Translation) -> some View {
        HStack {
            Picker(languages[languageIndex].language, selection: $languageIndex, content: {
                ForEach(languages.indices) { i in
                    Text(languages[i].language).tag(i)
                }
            })
            .pickerStyle(MenuPickerStyle())
            .padding()
            .accentColor(Color("Light Blue"))
            .accessibilityElement()
            .accessibilityLabel("Selected language to read translation is \(languages[languageIndex].language)")
            Spacer()
            Button {
                if !UIAccessibility.isVoiceOverRunning {
                    readOutLoud(translation)
                }
            } label: {
                Image(systemName: "speaker.wave.3.fill")
            }
            .padding()
            .accentColor(Color("Dark Blue"))
            .accessibilityElement()
            .accessibilityLabel("Listen")
            .accessibilityAction {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    readOutLoud(translation)
                })
            }
        }
    }
    
    func testView(for answerIndexes: [Int]) -> some View{
        ForEach(answerIndexes, id: \.self) { answer in
            Button {
                viewModel.selectTranslation(at: answer, from: translations)
            } label : {
                Text(translations[answer].translationOutput)
                    .padding(1)
                    .font(.title3)
                    .foregroundColor(color(for: answer))
                    .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 50)
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    func forwardButton() -> some View {
        Button {
            viewModel.updateStatus(translations)
        } label: {
            Image(systemName: "forward")
                .foregroundColor(Color("Dark Blue"))
                .frame(minWidth: UIScreen.main.bounds.width, minHeight: 44)
        }
        .padding(.top )
        .padding(.bottom, 64)
        .accessibilityLabel("Next question.")
    }
}

// MARK: - Private methods

private extension QuizView {
    
    func readOutLoud(_ translation: Translation) {
        let utterance = AVSpeechUtterance(string: translation.translationInput)
        utterance.voice = languages[languageIndex].voice
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    /// Determines the accessibility label of every level button, depending on the amount of translations that it has.
    /// - Parameter level: The level for which the accessibility label will be returned.
    /// - Returns: The accessibility label of the specified level.
    func accessibilityLabelForLevelButton(with level: Int) -> LocalizedStringKey {
        if viewModel.notAvailableTranslations(of: level) {
            return "There are no level \(Int16(level)) translations"
        } else {
            return "Show only level \(Int16(level)) translations"
        }
    }
    
    /// Determines the stroke width of the level buttons.
    /// - Parameter level: The level of a button
    /// - Returns: the stroke width that will have that button.
    func strokeWidth(for level: Int) -> CGFloat {
        Int16(level) == viewModel.currentLevel ? 1 : 0
    }
    
    /// This method handles all the actions that are run in the appearance of the view.
    func handleOnAppear() {
        if case .startQuiz(let transl, _) = appAction, let translation = transl {
            viewModel.request(translation: translation, in: translations)
        } else if case .startQuizMinLevel = appAction {
            viewModel.selectMinLevel(in: translations)
        } else {
            viewModel.updateStatus(translations)
        }
    }
    
    /// Code that will run when a new `AppAction` has been launched from outside the app: Siri shortcut, Spotlight, Widget, Quick Action...
    /// - Parameter appAction: The action performed.
    func handleAppAction( _ appAction: AppAction? = nil) {
        if case .startQuiz(let transl, _) = appAction, let translation = transl {
            viewModel.request(translation: translation, in: translations)
        } else if case .startQuizMinLevel = appAction {
            viewModel.selectMinLevel(in: translations)
        }
    }
    
    /// Correct answers will have a color and incorrect answers another.
    /// - Parameter answerIndex: The index of the answer selected by the user.
    /// - Returns: The color that will be applied to the answer.
    func color(for answerIndex: Int) -> Color {
        if case .on(let questionIndex, _, let selectedIndex) = viewModel.status, selectedIndex != nil {
            if answerIndex == questionIndex {
                return .green
            } else if answerIndex == selectedIndex {
                return .red
            }
        }
        return .init("Gray")
    }
}

// MARK: - Preview

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController.preview
        return QuizView(
            translations: .constant(
                [
                    .example(viewContext: dataController.container.viewContext, input: "1", output: "01", level: 1),
                    .example(viewContext: dataController.container.viewContext, input: "2", output: "02", level: 2),
                    .example(viewContext: dataController.container.viewContext, input: "3", output: "03", level: 3),
                    .example(viewContext: dataController.container.viewContext, input: "4", output: "04", level: 4)
                ]
            ),
            appAction: .constant(nil),
            viewModel: .init(dataController: dataController)
        )
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
