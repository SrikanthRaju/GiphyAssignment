//
//  CoreDataManager.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation
import CoreData

final class StoreData {

    enum StorageType {
        case inMemory, inDatabase

        fileprivate var container: NSPersistentContainer {
            switch self {
            case .inMemory:
                return StoreData.createPersistentContainer(inMemory: true)
            case .inDatabase:
                return StoreData.createPersistentContainer(inMemory: false)
            }
        }
    }

    static let inMemory = StoreData(type: .inMemory)
    static let inDatabase = StoreData(type: .inDatabase)

    private let container: NSPersistentContainer

    private init(type: StorageType) {
        self.container = type.container
    }


//    // MARK: - Core Data Saving support
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                if let pContext = context.parent {
                    saveContext(pContext)
                }
            } catch {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func viewContext() -> NSManagedObjectContext {
        return container.viewContext
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}

private extension StoreData {

    static func createPersistentContainer(inMemory: Bool) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Giphy")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}
