//
//  CacheManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()

    private init() {}

    private let cache = NSCache<NSString, NSData>()
    private let serialQueue = DispatchQueue(label: "digimonCacheSerialQueue")

    func insertImage(_ imageURLString: NSString, imageData: NSData?) {
        print("About to save to cache")
        if let imageData {
            print("Saving to cache")
            serialQueue.async {
                self.cache.setObject(imageData, forKey: imageURLString)
                self.saveToCoreData(imageData, name: imageURLString as String)
                print("Saved to cache")
            }
        }
    }

    func getImage(_ imageURLString: NSString, _ completion: @escaping (NSData?) -> Void) {
        print("Retrieving from cache")
        return serialQueue.async {
            if let imageInDisk = self.readFromCoreData(named: imageURLString as String) {
                print("Image is stored in disk")
                completion(imageInDisk)
            } else {
                print("Image is not stored in disk, using NSCache")
                completion(self.cache.object(forKey: imageURLString))
            }
        }
    }

    private func saveToCoreData(_ imageData: NSData, name: String) {
        print("Saving to disk")
        let coreDataManager = CoreDataManager.shared
        coreDataManager.saveImageDataToCoreData(imageData, name: name)
    }

    private func readFromCoreData(named name: String) -> NSData? {
        print("Reading from disk")
        let coreDataManager = CoreDataManager.shared
        return coreDataManager.getSavedImageData(named: name)
    }
}
