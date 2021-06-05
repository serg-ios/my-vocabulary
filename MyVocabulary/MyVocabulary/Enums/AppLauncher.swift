//
//  AppLauncher.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 1/6/21.
//

import Foundation

enum AppLauncher: Equatable {
    
    enum Action {
        case startQuiz(translation: Translation?)
    }
    
    case quick(action: Action)
    case siri(action: Action)
    case spotlight(action: Action)
    case widget(action: Action)
    
    // MARK: - Equatable
    
    static func ==(lhs: AppLauncher, rhs: AppLauncher) -> Bool {
        switch (lhs, rhs) {
        case (.quick(let lhsAction), .quick(let rhsAction)):
            if case .startQuiz(let lhsTranslation) = lhsAction, case .startQuiz(let rhsTranslation) = rhsAction {
                return lhsTranslation == rhsTranslation
            }
        case (.siri(let lhsAction), .siri(let rhsAction)):
            if case .startQuiz(let lhsTranslation) = lhsAction, case .startQuiz(let rhsTranslation) = rhsAction {
                return lhsTranslation == rhsTranslation
            }
        case (.spotlight(let lhsAction), .spotlight(let rhsAction)):
            if case .startQuiz(let lhsTranslation) = lhsAction, case .startQuiz(let rhsTranslation) = rhsAction {
                return lhsTranslation == rhsTranslation
            }
        case (.widget(let lhsAction), .widget(let rhsAction)):
            if case .startQuiz(let lhsTranslation) = lhsAction, case .startQuiz(let rhsTranslation) = rhsAction {
                return lhsTranslation == rhsTranslation
            }
        default:
            break
        }
        return false
    }
    
    // MARK: - Init
    
    init?(_ type: String, translation: Translation? = nil) {
        let startQuizAction: Action = .startQuiz(translation: translation)
        switch type {
        case "MyVocabulary://startQuiz":
            self = .quick(action: startQuizAction)
        case "com.serg-ios.MyVocabulary.startQuiz":
            self = .siri(action: startQuizAction)
        case "com.apple.corespotlightitem":
            self = .spotlight(action: startQuizAction)
        case "MultipleTranslationsWidget":
            self = .widget(action: startQuizAction)
        case "RandomTranslationWidget":
            self = .widget(action: startQuizAction)
        default:
            return nil
        }
    }
}
