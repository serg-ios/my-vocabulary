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
        @Published var appLauncher: AppLauncher?
        /// All the fetched translations that will be shared by all the views.
        @Published var translations: [Translation] = []

        let dataController: DataController
        private var translationsController: NSFetchedResultsController<Translation>

        init(dataController: DataController, appLauncher: AppLauncher?) {
            self.dataController = dataController
            let request: NSFetchRequest<Translation> = Translation.fetchRequest()
            request.sortDescriptors = []
            translationsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            self.appLauncher = appLauncher
            super.init()
            translationsController.delegate = self
            try? translationsController.performFetch()
            translations = translationsController.fetchedObjects ?? []
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
