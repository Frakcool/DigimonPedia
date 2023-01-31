//
//  DigimonViewModel.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 30/01/23.
//

import Foundation

protocol DigimonTableViewCellDelegate {
    func updateCellImage(_ imageData: Data?)
}

class DigimonViewModel {
    var digimon: Digimon
    var delegate: DigimonTableViewCellDelegate?
    
    private let cacheManager = CacheManager.shared
    private var networkManager = NetworkManager()

    init(digimon: Digimon) {
        self.digimon = digimon
    }

    func fetchImage(_ completion: (Data) -> Void) {
        let imageURLString = digimon.img

        print("About to get \(imageURLString)")
        cacheManager.getImage(imageURLString as NSString) { cachedImage in
            guard let cachedImage else {
                print("Loading from API")
                self.loadFromAPI(from: imageURLString)
                return
            }

            print("Successfully retrieved from cache \(imageURLString)")
            self.delegate?.updateCellImage(cachedImage as Data)
        }
    }

    private func loadFromAPI(from imageURLString: String) {
        networkManager.getImage(from: imageURLString) { data, error in
            guard error == nil, let data else {
                self.delegate?.updateCellImage(nil)
                return
            }

            self.cacheManager.insertImage(imageURLString as NSString, imageData: data as NSData)
            self.delegate?.updateCellImage(data as Data)
        }
    }
}
