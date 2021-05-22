//
//  SpreadsheetView+ViewModel.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 6/5/21.
//

import Foundation

extension SpreadsheetView {
    class ViewModel: NSObject, ObservableObject {

        enum Status: String {
            case loading
            case importable
            case imported
        }

        @Published var status: Status = .loading

        let spreadsheet: Spreadsheet
        let importAction: (() -> Void)?

        init(spreadsheet: Spreadsheet, importAction: (() -> Void)? = nil) {
            self.spreadsheet = spreadsheet
            self.importAction = importAction
        }

        func importTranslations() {
            status = .loading
            importAction?()
        }

        func checkIfImported(translations: [Translation]) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                for translation in self?.spreadsheet.translations ?? [] {
                    if !translations.contains(where: { $0.id == translation.id }) {
                        DispatchQueue.main.async { [weak self] in
                            self?.status = .importable
                        }
                        return
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.status = .imported
                }
            }
        }
    }
}
