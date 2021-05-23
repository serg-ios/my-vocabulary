//
//  Spreadsheet.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 14/3/21.
//

import Foundation
import CoreXLSX

/// Represents a parsed spreadsheet with its corresponding translations.
struct Spreadsheet {

    let id: String
    let name: String
    let translations: [Translation]

    /// Text that expresses the number of translations that contains the spreadsheet.
    var numberOfTranslationsString: String {
        String(format: NSLocalizedString("%d translations", comment: ""), translations.count).localizedUppercase
    }

    /// Represents a translation inside a spreadsheet, not the Core Data entity, before it's stored in iCloud.
    struct Translation: Identifiable, Hashable {
        /// The origin and aim language, the text to translate and the translation, identify univocally a translation.
        var id: String {
            from + to + input + output
        }
        let from: String
        let to: String
        let input: String
        let output: String

        // MARK: - Init

        internal init(from: String, to: String, input: String, output: String) {
            self.from = from
            self.to = to
            self.input = input
            self.output = output
        }

        /// The row must have text in 4 cells, otherwise the initializer returns `nil`.
        ///
        /// Google Translate spreadsheets have this format.
        /// - Parameters:
        ///   - row: Spreadsheet row.
        ///   - sharedStrings: shared strings of a `XLSXFile`.
        init?(row: Row, sharedStrings: SharedStrings) {
            let rowStrings = row.cells.compactMap({ $0.stringValue(sharedStrings) })
            if rowStrings.count == 4 {
                self.init(
                    from: rowStrings[0].localizedLowercase,
                    to: rowStrings[1].localizedLowercase,
                    input: rowStrings[2].localizedLowercase,
                    output: rowStrings[3].localizedLowercase
                )
            } else {
                return nil
            }
        }
    }

    // MARK: - Debug

    /// Creates a sample `Spreadsheet` with fake translations.
    static var example: Spreadsheet {
        Spreadsheet(
            id: "0",
            name: "My favorite book",
            translations: [
                .init(from: "english", to: "español", input: "hello", output: "hola"),
                .init(from: "english", to: "español", input: "bye", output: "adiós")
            ]
        )
    }
}
