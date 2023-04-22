//
//  CacheManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import Foundation

protocol PersistentCacheManager {
    func saveImage(_ imageData: NSData, name: String)
    func readImage(named name: String) -> NSData?
    func deleteImage(named name: String)
    func purgeCache()
}

class CacheManager {
    private let persistentCacheManager: PersistentCacheManager

    init(persistentCacheManager: PersistentCacheManager) {
        self.persistentCacheManager = persistentCacheManager
    }

    private let cache = NSCache<NSString, NSData>()
    private let serialQueue = DispatchQueue(label: "digimonCacheSerialQueue")

    func insertImage(_ imageURLString: NSString, imageData: NSData?) {
        print("About to save to cache \(imageURLString)")
        if let imageData {
            print("Saving to cache \(imageURLString)")
            serialQueue.async {
                self.cache.setObject(imageData, forKey: imageURLString)
                self.saveImageToPersistentCache(imageData, name: imageURLString as String)
                print("Saved to cache \(imageURLString)")
            }
        }
    }

    func getImage(_ imageURLString: String) -> NSData? {
        if let imageFromPersistentCache = getImageFromPersistentCache(imageURLString) {
            print("Image exists on persistent cache")
            return imageFromPersistentCache
        } else if let imageFromCache = getImageFromCache(imageURLString) {
            print("Image does not exist on core data, loading from NSCache \(imageURLString)")
            DispatchQueue.global().async {
                self.saveImageToPersistentCache(imageFromCache, name: imageURLString as String)
            }
            return imageFromCache
        }
        print("Image does not exist on cache")
        return nil
    }

    private func getImageFromPersistentCache(_ imageURLString: String) -> NSData? {
        print("Retrieving from persistent cache")
        return persistentCacheManager.readImage(named: imageURLString)
    }

    private func saveImageToPersistentCache(_ imageData: NSData, name: String) {
        persistentCacheManager.saveImage(imageData, name: name)
    }

    private func getImageFromCache(_ imageURLString: String) -> NSData? {
        print("Retrieving from cache \(imageURLString)")

        return self.cache.object(forKey: imageURLString as NSString)
    }
}
