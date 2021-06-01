//
//  ExternalLauncher.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 1/6/21.
//

import Foundation

enum ExternalLauncher: String {
    case quickAction = "MyVocabulary://startQuiz"
    case siriShortcut = "com.serg-ios.MyVocabulary.startQuiz"
    case spotlight = "com.apple.corespotlightitem"
    case multipleTranslationsWidget = "MultipleTranslationsWidget"
    case randomTranslationWidget = "RandomTranslationWidget"
}
