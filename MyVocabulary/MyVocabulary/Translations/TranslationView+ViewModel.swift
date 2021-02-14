//
//  QuizView+ViewModel.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 13/5/21.
//

import Foundation

extension TranslationsView {
    class ViewModel: NSObject, ObservableObject {
        
        enum Status {
            case empty
            case loaded(filteredTranslations: [Translation])
            
            static func ==(lhs: Status, rhs: Status) -> Bool {
                switch (lhs, rhs) {
                case (.empty , .loaded):
                    return false
                case(.loaded(let lhsFilteredTranslations), .loaded(let rhsFilteredTranslations)):
                    return lhsFilteredTranslations == rhsFilteredTranslations
                default:
                    return true
                }
            }
        }
        
        @Published var status: Status = .empty
        @Published var searchString: String = ""
        
        private let dataController: DataController
        
        init(dataController: DataController) {
            self.dataController = dataController
        }
        
        func updateStatus(for translations: [Translation]) {
            if translations.isEmpty {
                status = .empty
            } else if searchString.isEmpty {
                status = .loaded(filteredTranslations: translations.sorted(by: { $0.level > $1.level }))
            } else {
                let filteredTranslations = translations.filter {
                    $0.translationInput.localizedLowercase.contains(searchString.localizedLowercase)
                }.sorted(by: { $0.level > $1.level })
                status = .loaded(filteredTranslations: filteredTranslations)
            }
        }
        
        func deleteAll() {
            dataController.deleteAll(Translation.self)
            searchString = ""
            status = .empty
            dataController.save()
        }
    }
}
