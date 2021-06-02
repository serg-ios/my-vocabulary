//
//  ExternalLauncher.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 1/6/21.
//

import Foundation

enum ExternalLauncher: Equatable {
    case quickAction
    case siriShortcut
    case spotlight(translation: Translation?)
    case multipleTranslationsWidget
    case randomTranslationWidget
    
    private static let quickActionType = "MyVocabulary://startQuiz"
    private static var siriShortcutType = "com.serg-ios.MyVocabulary.startQuiz"
    private static var spotlightType = "com.apple.corespotlightitem"
    private static var multipleTranslationsWidgetType = "MultipleTranslationsWidget"
    private static var randomTranslationWidgetType = "RandomTranslationWidget"
    
    static func ==(lhs: ExternalLauncher, rhs: ExternalLauncher) -> Bool {
        switch (lhs, rhs) {
        case (.spotlight(let lhsTranslation), .spotlight(let rhsTranslation)):
            return lhsTranslation == rhsTranslation
        default:
            return lhs.string == rhs.string
        }
    }
    
    init?(_ type: String, translation: Translation? = nil) {
        switch type {
        case Self.quickActionType:                self = .quickAction
        case Self.siriShortcutType:               self = .siriShortcut
        case Self.spotlightType:                  self = .spotlight(translation: translation)
        case Self.multipleTranslationsWidgetType: self = .multipleTranslationsWidget
        case Self.randomTranslationWidgetType:    self = .randomTranslationWidget
        default:                                  return nil
        }
    }
    
    /// The activity type of the launcher.
    var string: String {
        switch self {
        case .quickAction:                return Self.quickActionType
        case .siriShortcut:               return Self.siriShortcutType
        case .spotlight:                  return Self.spotlightType
        case .multipleTranslationsWidget: return Self.multipleTranslationsWidgetType
        case .randomTranslationWidget:    return Self.randomTranslationWidgetType
        }
    }
}
