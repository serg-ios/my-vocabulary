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
        
        @Published var currentLevel: Int16?
        @Published var status: Status = .off
        
        private var availableLevels = Set<Int>()
        private let numberOfAnswers = 4
        private let dataController: DataController
        
        init(dataController: DataController) {
            self.dataController = dataController
            super.init()
        }
        
        /// Selects a new translation randomly, among all the available translations.
        ///
        /// When there is a current level selected, filters the translations to find only those with the specified level.
        /// - Parameter translations: The available translations among which the random translation will be chosen.
        func updateStatus(_ translations: [Translation]) {
            // The first time, initalize the available levels' array.
            if status == .off {
                availableLevels = Set(translations.compactMap({ Int($0.level) }))
            }
            // There must be enough translations to start the quiz, otherwise the game is disabled.
            guard translations.count >= numberOfAnswers else {
                status = .off
                return
            }
            // Filter translations if there is a current level selected.
            var filteredTranslations = [Translation]()
            if let level = currentLevel {
                filteredTranslations = translations.filter({ $0.level == level })
            }
            // If there are no translations of the current level, the index is obtained from the unfiltered array.
            var questionIndex: Int!
            if filteredTranslations.isEmpty {
                questionIndex = Int.random(in: 0..<translations.count)
            } else {
                questionIndex = Int.random(in: 0..<filteredTranslations.count)
                questionIndex = translations.firstIndex(of: filteredTranslations[questionIndex])
            }
            // The answers must not be repeated, so Set is used instead of Array.
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
            availableLevels = Set(translations.compactMap({ Int($0.level) }))
            clearLevelIfNeeded(translations)
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
        
        /// Determines if the translations array contains at least one translation of the level.
        /// - Parameters:
        ///   - level: Translation's level we are looking for.
        /// - Returns: `true` if there are NOT translations with the specified level in the array.
        func notAvailableTranslations(of level: Int) -> Bool {
            !availableLevels.contains(level)
        }
        
        /// Update view model's status to show only translations with the specified level.
        /// - Parameters:
        ///   - translations: Current array of translations that is being shown in the quiz.
        ///   - level: Only translations with this level will be questioned in the quiz.
        func show(_ translations: [Translation], with level: Int) {
            currentLevel = Int16(level)
            updateStatus(translations)
        }
        
        /// Call this method after every answer, to determine if there are not more translations of the current level. In that case, set the current level to `nil`.
        /// - Parameter translations: Array of translations in which a translation with the current level will be searched for.
        func clearLevelIfNeeded(_ translations: [Translation]) {
            guard let level = currentLevel, !translations.contains(where: { $0.level == level }) else { return }
            currentLevel = nil
        }
        
        /// Call this method to clean make current level `nil`.
        ///
        /// Must be called when the quiz finishes.
        func clearLevel() {
            currentLevel = nil
        }
        
        /// If the new level is different to the currently selected, the level changes. If it's the same, the current level is set to `nil`.
        /// - Parameters:
        ///   - level: The new level.
        ///   - translations: The translations that will be filtered based on the new level.
        func changeLevel(to level: Int, with translations: [Translation]) {
            if Int16(level) != currentLevel {
                show(translations, with: level)
            } else {
                currentLevel = nil
                updateStatus(translations)
            }
        }
        
        /// Selects the lowest level available.
        /// - Parameter translations: The translations of the quiz.
        func selectMinLevel(in translations: [Translation]) {
            let minLevel = availableLevels.min() ?? 0
            if Int16(minLevel) != currentLevel {
                changeLevel(to: minLevel, with: translations)
            } else {
                updateStatus(translations)
            }
        }
    }
}
