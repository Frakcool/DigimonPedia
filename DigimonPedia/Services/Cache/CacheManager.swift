//
//  CacheManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import UIKit

class CacheManager {
    static let shared = CacheManager()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func insertImage(_ imageURLString: NSString, image: UIImage) {
        cache.setObject(image, forKey: imageURLString)
    }

    func getImage(_ imageURLString: NSString) -> UIImage? {
        cache.object(forKey: imageURLString)
    }
}
