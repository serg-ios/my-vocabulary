//
//  QuizView+ViewModel.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import Foundation

extension QuizView {
    class ViewModel: NSObject, ObservableObject {
        
        enum Status: Equatable {
            case off
            case on(questionIndex: Int, answerIndexes: [Int], selectedIndex: Int?)
            
            static func ==(lhs: Status, rhs: Status) -> Bool {
                switch (lhs, rhs) {
                case (.off, .on):
                    return false
                case (.on(let lhsQuestionIndex, let lhsAnswerIndexes, let lhsSelectedIndex),
                      .on(let rhsQuestionIndex, let rhsAnswerIndexes, let rhsSelectedIndex)):
                    return lhsQuestionIndex == rhsQuestionIndex
                        && lhsAnswerIndexes == rhsAnswerIndexes
                        && lhsSelectedIndex == rhsSelectedIndex
                default:
                    return true
                }
            }
        }
        
        @Published var status: Status = .off
        
        private let numberOfAnswers = 4
        private let dataController: DataController
        
        init(dataController: DataController) {
            self.dataController = dataController
            super.init()
        }
        
        /// Selects a new translation randomly, among all the available translations.
        /// - Parameter translations: The available translations among which the random translation will be chosen.
        func updateStatus(_ translations: [Translation]) {
            guard translations.count >= numberOfAnswers else {
                status = .off
                return
            }
            let questionIndex = Int.random(in: 0..<translations.count)
            var answerIndexes: Set<Int> = [questionIndex]
            while answerIndexes.count < numberOfAnswers {
                answerIndexes.insert(Int.random(in: 0..<translations.count))
            }
            status = .on(questionIndex: questionIndex, answerIndexes: answerIndexes.shuffled(), selectedIndex: nil)
        }
        
        /// Receives an answer and updates the status accordingly to the result of the answer.
        /// - Parameters:
        ///   - selectedIndex: The index of the selected answer.
        ///   - translations: The array of translations, needed to check if the answer is correct, given all the indexes.
        func selectTranslation(at selectedIndex: Int, from translations: [Translation]) {
            guard case .on(let questionIndex, let answerIndexes, nil) = status else {
                return
            }
            status = .on(questionIndex: questionIndex, answerIndexes: answerIndexes, selectedIndex: selectedIndex)
            if selectedIndex == questionIndex {
                translations[questionIndex].increaseLevel()
            } else {
                translations[questionIndex].decreaseLevel()
            }
            dataController.update(translations[questionIndex])
        }
        
        /// Requests a specific translation, instead of doing it randomly.
        /// - Parameters:
        ///   - translation: The translation that should be requested in the quiz.
        ///   - translations: The array of translations that are being requested in the quiz.
        func request(translation: Translation, in translations: [Translation]) {
            guard let questionIndex = translations.firstIndex(of: translation) else { return }
            var answerIndexes = Set<Int>()
            answerIndexes.insert(questionIndex)
            while answerIndexes.count < numberOfAnswers {
                answerIndexes.insert(Int.random(in: 0..<translations.count))
            }
            status = .on(questionIndex: questionIndex, answerIndexes: answerIndexes.shuffled(), selectedIndex: nil)
        }
    }
}

