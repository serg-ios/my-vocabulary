//
//  QuizView.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 21/3/21.
//

import SwiftUI

struct QuizView: View {
    
    @Binding private var translations: [Translation]
    @StateObject private var viewModel: ViewModel
    
    init(translations: Binding<[Translation]>, viewModel: ViewModel) {
        self._translations = translations
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if case .on(let questionIndex, let answerIndexes, _) = viewModel.status,
                   questionIndex < translations.count
                {
                    Spacer()
                    VStack(spacing: 16) {
                        Text(translations[questionIndex].translationInput).font(.largeTitle).bold()
                            .lineLimit(1)
                        SegmentedProgressBar(level: translations[questionIndex].level).frame(height: 8)
                    }.padding([.leading, .trailing, .bottom])
                    ForEach(answerIndexes, id: \.self) { answer in
                        Button {
                            viewModel.selectTranslation(at: answer, from: translations)
                        } label : {
                            Text(translations[answer].translationOutput)
                                .padding(1)
                                .font(.title3)
                                .foregroundColor(color(for: answer))
                                .frame(maxWidth: UIScreen.main.bounds.width, minHeight: 50)
                                .minimumScaleFactor(0.1)
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
                } else {
                    PlaceholderView(
                        image: Image(systemName: "die.face.4"),
                        text: Text("You must have at least 4 translations to start the quiz.")
                    )
                    .navigationTitle("Quiz")
                }
            }
            .onChange(of: translations, perform: viewModel.updateStatus(_:))
            .onAppear { viewModel.updateStatus(translations) }
        }
    }
    
    
    private func color(for answerIndex: Int) -> Color {
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
            viewModel: .init(dataController: dataController)
        )
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
