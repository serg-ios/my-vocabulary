//
//  AppAction.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 1/6/21.
//

import Foundation

/// External action that will open the app: Quick Action, Siri Shortcut, Spotlight, Widget..
///
/// Each action is univocally identified by the date in which it was performed, as it's impossible to launch more than one action at a time.
enum AppAction: Equatable {
    
    case startQuiz(translation: Translation?, date: Date)
    case startQuizMinLevel(date: Date)
    
    // MARK: - Equatable
    
    static func ==(lhs: AppAction, rhs: AppAction) -> Bool {
        switch (lhs, rhs) {
        case (.startQuiz(_, let lhsDate), .startQuiz(_, let rhsDate)):
            return lhsDate == rhsDate
        case (.startQuizMinLevel(let lhsDate), .startQuizMinLevel(let rhsDate)):
            return lhsDate == rhsDate
        default:
            return false
        }
    }
    
    // MARK: - Init
    
    init?(_ type: String, translation: Translation? = nil) {
        switch type {
        case SiriShortcuts.startQuiz.rawValue,          // Start quiz from Siri Shortcut.
             "MyVocabulary://startQuiz",                // Start quiz from Quick Action.
             "com.apple.corespotlightitem",             // Start quiz from Spotlight.
             "RandomTranslationWidget":                 // Start quiz from Random Translation widget.
            self = .startQuiz(translation: translation, date: Date())
        case "MyVocabulary://startQuizMinLevel",        // Start quiz with difficult translations from Quiz Action.
             "MultipleTranslationsWidget",              // Start quiz with difficult translations from widget.
            SiriShortcuts.startQuizMinLevel.rawValue:   //Start quiz with difficult translations from Siri Shortcut.
            self = .startQuizMinLevel(date: Date())
        default:
            return nil
        }
    }
}
