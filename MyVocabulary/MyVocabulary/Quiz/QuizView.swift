//
//  QuizView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 21/3/21.
//

import SwiftUI

struct QuizView: View {
    
    @Binding private var appAction: AppAction?
    @Binding private var translations: [Translation]
    @StateObject private var viewModel: ViewModel
    
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
            VStack {
                if case .on(let questionIndex, let answerIndexes, _) = viewModel.status,
                   questionIndex < translations.count
                {
                    HStack {
                        ForEach(0...Int(Translation.maxLevel), id: \.self) { level in
                            Button("\(level)") {
                                viewModel.changeLevel(to: level, with: translations)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .disabled(viewModel.notAvailableTranslations(of: level))
                            .overlay(Circle().stroke(Color(UIColor.label), lineWidth: strokeWidth(for: level)))
                            .minimumScaleFactor(0.5)
                            .accentColor(Color("Light Blue"))
                        }
                    }
                    .padding()
                    let translation = translations[questionIndex]
                    Spacer()
                    VStack(spacing: 16) {
                        Text(translation.translationInput).font(.largeTitle).bold()
                            .lineLimit(1)
                        SegmentedProgressBar(level: translation.level).frame(height: 8)
                    }
                    .padding([.leading, .trailing, .bottom])
                    .accessibilityElement()
                    .accessibilityLabel("\(translation.translationInput). Level \(translation.level).")
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
                    Spacer()
                    Button {
                        viewModel.updateStatus(translations)
                    } label: {
                        Image(systemName: "forward")
                            .foregroundColor(Color("Gray"))
                            .frame(minWidth: UIScreen.main.bounds.width, minHeight: 44)
                    }
                    .padding(.top )
                    .padding(.bottom, 64)
                    .accessibilityLabel("Next question.")
                } else {
                    PlaceholderView(
                        image: Image(systemName: "die.face.4"),
                        text: Text("You must have at least 4 translations to start the quiz.")
                    )
                    .navigationTitle("Quiz")
                }
            }
            .onChange(of: translations, perform: viewModel.updateStatus(_:))
            .onAppear(perform: handleOnAppear)
            .onChange(of: viewModel.status, perform: {
                guard case .on(let answer, _, let selected) = $0, selected != nil, answer != selected else { return }
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            })
            .onChange(of: appAction, perform: handleAppAction)
        }
    }
}

// MARK: - Private methods

private extension QuizView {
    
    func strokeWidth(for level: Int) -> CGFloat {
        Int16(level) == viewModel.currentLevel ? (1 / UIScreen.main.scale) : 0
    }
    
    /// This method handles all the actions that are run in the appearance of the view.
    func handleOnAppear() {
        if case .startQuiz(let transl, _) = appAction, let translation = transl {
            viewModel.request(translation: translation, in: translations)
        } else {
            viewModel.updateStatus(translations)
        }
    }
    
    /// Code that will run when a new `AppAction` has been launched from outside the app: Siri shortcut, Spotlight, Widget, Quick Action...
    /// - Parameter appAction: The action performed.
    func handleAppAction( _ appAction: AppAction? = nil) {
        if case .startQuiz(let transl, _) = appAction, let translation = transl {
            viewModel.request(translation: translation, in: translations)
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
