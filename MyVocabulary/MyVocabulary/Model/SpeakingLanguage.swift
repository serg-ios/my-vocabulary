//
//  SpeakingLanguage.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 30/6/21.
//

import Foundation
import AVFoundation

/// Identifies an `AVSpeechSynthesisVoice`.
struct SpeakingLanguage: Comparable {
    /// A voice that can be used to read a text.
    var voice: AVSpeechSynthesisVoice
    /// Human understandably language name.
    var language: String
    
    // MARK: - Comparable

    static func < (lhs: SpeakingLanguage, rhs: SpeakingLanguage) -> Bool {
        lhs.language < rhs.language
    }
}
