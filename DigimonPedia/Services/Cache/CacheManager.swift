//
//  CacheManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import UIKit

class CacheManager {
    static let shared = CacheManager()

    private init() {}

    private let cache = NSCache<NSString, UIImage>()
    private let serialQueue = DispatchQueue(label: "digimonCacheSerialQueue")

    func insertImage(_ imageURLString: NSString, image: UIImage?) {
        print("About to save to cache")
        if let image {
            print("Saving to cache")
            serialQueue.async {
                self.cache.setObject(image, forKey: imageURLString)
                print("Saved to cache")
            }
        }
    }

    func getImage(_ imageURLString: NSString, completion: @escaping (UIImage?) -> Void) {
        print("Retrieving from cache")
        return serialQueue.async {
            completion(self.cache.object(forKey: imageURLString))
        }
    }
}
