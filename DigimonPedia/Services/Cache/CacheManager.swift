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
                print("Saved to cache")
            }
        }
    }

    func getImage(_ imageURLString: NSString, _ completion: @escaping (NSData?) -> Void) {
        print("Retrieving from cache")
        return serialQueue.async {
            completion(self.cache.object(forKey: imageURLString))
        }
    }
}
