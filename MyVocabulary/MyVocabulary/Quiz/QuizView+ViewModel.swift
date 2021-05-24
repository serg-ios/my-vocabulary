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
    }
}

