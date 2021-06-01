//
//  ContentView+ViewModel.swift
//  MyVocabulary
//
//  Created by Sergio Rodríguez Rama on 6/5/21.
//

import CoreData
import Foundation

extension ContentView {
    class ViewModel: NSObject, ObservableObject {
        
        /// Determines which iOS element launched the app: siri shortcut, quick action, widget, spotlight...
        @Published var externalLauncher: ExternalLauncher?
        @Published var translations: [Translation] = []

        let dataController: DataController
        private var translationsController: NSFetchedResultsController<Translation>

        init(dataController: DataController) {
            self.dataController = dataController
            let request: NSFetchRequest<Translation> = Translation.fetchRequest()
            request.sortDescriptors = []
            translationsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            translationsController.delegate = self
            try? translationsController.performFetch()
            translations = translationsController.fetchedObjects ?? []
        }
        
        /// Sets the external caller to `nil`.
        func cleanExternalLauncher() {
            externalLauncher = nil
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate methods

extension ContentView.ViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let newTranslations = controller.fetchedObjects as? [Translation] {
            translations = newTranslations
        }
    }
}
