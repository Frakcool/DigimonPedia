//
//  DigimonViewModel.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 30/01/23.
//

import UIKit

protocol DigimonTableViewCellDelegate {
    func updateCellImage(_ image: UIImage?)
}

class DigimonViewModel {
    var digimon: Digimon
    var image: UIImage!
    var delegate: DigimonTableViewCellDelegate!
    
    private let cacheManager = CacheManager.shared
    private var networkManager = NetworkManager()

    init(digimon: Digimon) {
        self.digimon = digimon
    }

    func updateImage() {
        let imageURLString = digimon.img

        print("About to get \(imageURLString)")
        cacheManager.getImage(imageURLString as NSString, completion: { cachedImage in
            guard let cachedImage else {
                print("Loading from API")
                self.loadFromAPI(from: imageURLString)
                return
            }

            print("Successfully retrieved from cache \(imageURLString)")
            self.image = cachedImage
            self.delegate.updateCellImage(self.image)
        })
    }

    private func loadFromAPI(from imageURLString: String) {
        networkManager.getImage(from: imageURLString) { data, error in
            guard error == nil, let data else {
                self.image = UIImage(named: "broken_image")
                self.delegate.updateCellImage(self.image)
                return
            }

            self.image = UIImage(data: data)
            self.cacheManager.insertImage(imageURLString as NSString, image: self.image)
            self.delegate.updateCellImage(self.image)
        }
    }
}
