//
//  DigimonTableViewCellDataManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 28/01/23.
//

import UIKit

protocol DigimonTableViewCellProtocol {
    func updateImage()
}

class DigimonTableViewCellDataManager {
    // Why using a singleton causes the images to be out of sync?
    // Happens the same when trying to use cached images

    var image: UIImage?
    var delegate: DigimonTableViewCellProtocol?

    private let cacheManager = CacheManager()
    private var networkManager: NetworkManager!
    private let serialQueue = DispatchQueue(label: "dataManagerSerialQueue")

    init() {
        networkManager = NetworkManager()
    }

    func getImage(from imageURLString: String) {
        print("About to get \(imageURLString)")
        guard let cachedImage = cacheManager.getImage(imageURLString as NSString) else {
            print("Loading from API")
            serialQueue.sync {
                loadFromAPI(from: imageURLString)
            }
            return
        }
        print("Successfully retrieved from cache \(imageURLString)")
        serialQueue.sync {
            self.image = cachedImage
        }
    }

    private func loadFromAPI(from imageURLString: String) {
        networkManager.getImage(from: imageURLString) { data, error in
            guard error == nil, let data else {
                self.image = UIImage(named: "broken_image")
                self.delegate?.updateImage()
                return
            }

            self.image = UIImage(data: data)
            self.cacheManager.insertImage(imageURLString as NSString, image: self.image)
            self.delegate?.updateImage()
        }
    }
}
