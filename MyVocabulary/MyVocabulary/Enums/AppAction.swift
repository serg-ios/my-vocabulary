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
    
    // MARK: - Equatable
    
    static func ==(lhs: AppAction, rhs: AppAction) -> Bool {
        switch (lhs, rhs) {
        case (.startQuiz(_, let lhsDate), .startQuiz(_, let rhsDate)):
            return lhsDate == rhsDate
        }
    }
    
    // MARK: - Init
    
    init?(_ type: String, translation: Translation? = nil) {
        switch type {
        case SiriShortcuts.startQuiz.rawValue,          // Start quiz from Siri Shortcut.
             "MyVocabulary://startQuiz",                // Start quiz from Quick Action.
             "com.apple.corespotlightitem",             // Start quiz from Spotlight.
             "MultipleTranslationsWidget",              // Start quiz from Multiple Translations widget.
             "RandomTranslationWidget":                 // Start quiz from Random Translation widget.
            self = .startQuiz(translation: translation, date: Date())
        default:
            return nil
        }
    }
}
