//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Sergio Rodríguez Rama on 25/1/21.
//

import CoreData
import SwiftUI
import CoreSpotlight

class DataController: ObservableObject {

    let container: NSPersistentCloudKitContainer

    // MARK: - Init

    private static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        return managedObjectModel
    }()

    /// For testing and previewing purposes, we create a temporary in-memory database by writing to `/dev/null`
    /// so our data is destroyed after the app finishes running.
    /// - Parameter inMemory: If  `true`, data will be temporary written in `/dev/null`, is `false` by default.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Spotlight
    
    /// Updates a translation in CloudKit and adds it to Spotlight.
    /// - Parameter translation: The translation that will be updated.
    func update(_ translation: Translation) {
        let translationID = translation.objectID.uriRepresentation().absoluteString
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = translation.translationInput
        attributeSet.contentDescription = translation.translationOutput
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: translationID,
            domainIdentifier: "com.serg-ios.MyVocabulary",
            attributeSet: attributeSet
        )
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        save()
    }

    // MARK: - Actions

    /// Save model changes in iCloud.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    /// Delete a specific object from iCloud.
    /// - Parameter object: The object to delete.
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }

    /// Delete all the objects of a specific type from iCloud and removes all Spotlight data.
    /// - Parameter objectType: The type of the objects that will be removed.
    func deleteAll(_ objectType: NSManagedObject.Type) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = objectType.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? container.viewContext.executeAndMergeChanges(using: batchDeleteRequest)
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["com.serg-ios.MyVocabulary"])
    }

    /// Gives the number of elements fetched.
    /// - Parameter fetchRequest: The request that fetched the elements.
    /// - Returns: The number of elements.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    // MARK: - Debug

    /// Generates a `DataController` that will write data in `/dev/null`, so the user's data will never be affected.
    ///
    /// For debugging purposes.
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext
        return dataController
    }()
}
