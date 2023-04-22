//
//  CoreDataManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 08/03/23.
//

import CoreData
import UIKit

class CoreDataManager: PersistentCacheManager {
    private static let entityName = "DigimonImage"
    private static let containerName = "DigimonCoreDataModel"

    static let shared = CoreDataManager()

    private init() {
        let path = NSPersistentContainer
            .defaultDirectoryURL()
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        print(path ?? "Not found")
    }

    func saveImage(_ imageData: NSData, name: String) {
        guard readImage(named: name) == nil else {
            print("Image already exists, skipping save")
            return
        }

        DispatchQueue.global().async {
            print("Saving image to core data")
            let context = self.persistentContainer.viewContext
            guard let entity = NSEntityDescription.entity(forEntityName: CoreDataManager.entityName, in: context) else {
                return
            }
            let imageObject = NSManagedObject(entity: entity, insertInto: context)
            imageObject.setValue(imageData, forKey: #keyPath(DigimonImage.imageData))
            imageObject.setValue(name, forKey: #keyPath(DigimonImage.imageName))

            self.saveContext()

            print("Image saved to core data")
        }
    }

    func readImage(named name: String) -> NSData? {
        print("Reading image from core data")

        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataManager.entityName)
        request.predicate = NSPredicate(format: "imageName == %@", name)
        request.fetchLimit = 1

        do {
            let result = try context.fetch(request)
            let imageObject = result.first as? NSManagedObject
            print("Image found in core data")
            return imageObject?.value(forKey: #keyPath(DigimonImage.imageData)) as? NSData
        } catch let error as NSError {
            print("Could not fetch image. \(error), \(error.userInfo)")
            return nil
        }
    }

    func deleteImage(named name: String) {
        DispatchQueue.global().async {
            print("Deleting image from core data")

            let context = self.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataManager.entityName)
            request.predicate = NSPredicate(format: "imageName == %@", name)
            request.fetchLimit = 1

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Image deleted from core data")
            } catch let error as NSError {
                print("Could not delete image. \(error), \(error.userInfo)")
            }
        }
    }

    func purgeCache() {
        DispatchQueue.global().async {
            print("Purging core data")

            let context = self.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: CoreDataManager.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
            } catch let error as NSError {
                print("Could not purge code data. \(error), \(error.userInfo)")
            }

            print("Purged Core Data")
        }
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManager.containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}
