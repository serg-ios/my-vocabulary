//
//  Translation+CoreData.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/3/21.
//

import Foundation
import CoreData

extension Translation {

    /// The maximum level of knowledge of a translation.
    static var maxLevel: Int16 { 5 }

    // MARK: - Identifiable

    /// The origin and aim language, the text to translate and the translation, identify univocally a translation.
    public var id: String {
        translationFrom + translationTo + translationInput + translationOutput
    }

    // MARK: - Core data

    /// Unwrapped `from` property.
    var translationFrom: String {
        from ?? "Error: unknown input language."
    }

    /// Unwrapped `to` property.
    var translationTo: String {
        to ?? "Error: unknown output language."
    }

    /// Unwrapped `input` property.
    var translationInput: String {
        input ?? "Error: unknown input text."
    }

    /// Unwrapped `output` property.
    var translationOutput: String {
        output ?? "Error: unknown output text."
    }

    // MARK: - Setters

    /// Increases the level in 1, with a maximum of 5.
    func increaseLevel() {
        level = min(level + 1, 5)
    }

    /// Decreases the level in 1, with a minimum of 0.
    func decreaseLevel() {
        level = max(level - 1, 0)
    }

    // MARK: - Debug

    /// Creates a sample translation.
    ///
    /// Use `DataController.preview` to prevent this sample from being stored as user's legit data.
    /// - Parameter viewContext: The context of the `NSPersistentCloudKitContainer`.
    /// - Returns: The translation initialized and stored.
    static func example(
        viewContext: NSManagedObjectContext,
        from: String = "english",
        to: String = "spanish",
        input: String = "hello",
        output: String = "hola",
        level: Int16 = 4
    ) -> Translation {
        let translation = Translation(context: viewContext)
        translation.from = from
        translation.to = to
        translation.input = input
        translation.output = output
        translation.level = level
        return translation
    }
}
