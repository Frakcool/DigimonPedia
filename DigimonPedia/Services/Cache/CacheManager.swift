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
        print("About to save to cache \(imageURLString)")
        if let imageData {
            print("Saving to cache \(imageURLString)")
            serialQueue.async {
                self.cache.setObject(imageData, forKey: imageURLString)
                self.saveToCoreData(imageData, name: imageURLString as String)
                print("Saved to cache \(imageURLString)")
            }
        }
    }

    func getImage(_ imageURLString: String) -> NSData? {
        if let imageFromCoreData = getImageFromCoreData(imageURLString) {
            print("Image exists on core data \(imageURLString)")
            return imageFromCoreData
        } else if let imageFromCache = getImageFromCache(imageURLString) {
            print("Image does not exist on core data, loading from NSCache \(imageURLString)")
            DispatchQueue.global().async {
                self.saveToCoreData(imageFromCache, name: imageURLString as String)
            }
            return imageFromCache
        }
        print("Image not in cache \(imageURLString)")
        return nil
    }

    private func getImageFromCoreData(_ imageURLString: String) -> NSData? {
        print("Retrieving from core data \(imageURLString)")

        return self.readFromCoreData(named: imageURLString)
    }

    private func getImageFromCache(_ imageURLString: String) -> NSData? {
        print("Retrieving from cache \(imageURLString)")

        return self.cache.object(forKey: imageURLString as NSString)
    }

    private func saveToCoreData(_ imageData: NSData, name: String) {
        print("Saving to core data \(name)")
        let coreDataManager = CoreDataManager.shared
        coreDataManager.saveImageDataToCoreData(imageData, name: name)
    }

    private func readFromCoreData(named name: String) -> NSData? {
        print("Reading from core data \(name)")
        let coreDataManager = CoreDataManager.shared
        return coreDataManager.getSavedImageData(named: name)
    }
}
