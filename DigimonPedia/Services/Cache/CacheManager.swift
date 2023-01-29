//
//  CacheManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import UIKit

class CacheManager {
    private let cache = NSCache<NSString, UIImage>()
    private let serialQueue = DispatchQueue(label: "digimonCacheSerialQueue")

    func insertImage(_ imageURLString: NSString, image: UIImage?) {
        print("About to save to cache")
        if let image {
            print("Saving to cache")
            serialQueue.sync {
                cache.setObject(image, forKey: imageURLString)
            }
        }
    }

    func getImage(_ imageURLString: NSString) -> UIImage? {
        print("Retrieving from cache")
        return serialQueue.sync {
            cache.object(forKey: imageURLString)
        }
    }
}
