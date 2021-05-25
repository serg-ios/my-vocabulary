//
//  ImportView+ViewModel.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 3/5/21.
//

import Foundation
import CoreData
import GoogleSignIn
import GoogleAPIClientForREST
import WidgetKit

extension ImportView {

    // MARK: - Mock view model

    class ViewModelMock: ViewModel {

        var statusMock: ImportView.ViewModel.Status

        override var status: ImportView.ViewModel.Status { statusMock }

        init(status: ImportView.ViewModel.Status) {
            self.statusMock = status
            super.init(
                dataController: .preview,
                googleController: (UIApplication.shared.delegate as! AppDelegate).googleSignDelegate
            )
        }
    }

    // MARK: - View model

    class ViewModel: NSObject, ObservableObject {

        enum Status {
            case off
            case loading
            case loaded(spreadsheets: [Spreadsheet])
        }

        private let dataController: DataController

        @Published private(set) var googleController: GoogleController
        @Published private(set) var status: Status = .off {
            didSet {
                if case .loading = status {
                    googleController.fetchAllSpreadsheets { [weak self] in
                        self?.updateStatus()
                    }
                }
            }
        }

        init(dataController: DataController, googleController: GoogleController) {
            self.dataController = dataController
            self.googleController = googleController
            super.init()
        }

        // MARK: - Public methods

        func updateStatus() {
            switch (googleController.signInStatus, googleController.spreadsheetsResult) {
            case (.ok(signedIn: true), .success(let spreadsheets)):
                status = .loaded(spreadsheets: spreadsheets)
            case (.ok(signedIn: true), nil):
                status = .loading
            default:
                status = .off
            }
        }

        func tryToRestoreSession() {
            guard case .off = status, hasPreviousSignIn() else { return }
            GIDSignIn.sharedInstance().restorePreviousSignIn()
        }

        func importTranslations(from spreadsheet: Spreadsheet, alreadyImported translations: [Translation]) {
            dataController.container.viewContext.automaticallyMergesChangesFromParent = true
            dataController.container.performBackgroundTask { [weak self] context in
                for translation in spreadsheet.translations {
                    guard self?.hasBeenImported(translation, in: translations) == true else { continue }
                    let newTranslation = Translation(context: context)
                    newTranslation.from = translation.from
                    newTranslation.to = translation.to
                    newTranslation.input = translation.input
                    newTranslation.output = translation.output
                }
                try? context.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }

        func signOut() {
            googleController.signOut()
            status = .off
        }

        func signIn() {
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
}

// MARK: - Private methods

private extension ImportView.ViewModel {
    func hasBeenImported(_ translation: Spreadsheet.Translation, in translations: [Translation]) -> Bool {
        !translations.contains(where: { $0.id == translation.id })
    }

    func hasPreviousSignIn() -> Bool {
        GIDSignIn.sharedInstance()?.hasPreviousSignIn() == true
    }
}
