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

    func fetchImage() async -> Data? {
        let imageURLString = digimon.img

        print("About to get \(imageURLString)")
        guard let cachedImage = cacheManager.getImage(imageURLString) else {
            print("Loading from API")
            guard let imageData = await self.loadFromAPI(from: imageURLString) else {
                return nil
            }
            return imageData
        }

        print("Successfully retrieved from cache \(imageURLString)")
        self.delegate?.updateCellImage(cachedImage as Data)
        return cachedImage as Data
    }

    private func loadFromAPI(from imageURLString: String) async -> Data? {
        do {
            let data = try await networkManager.getImage(from: imageURLString)
            self.cacheManager.insertImage(imageURLString as NSString, imageData: data as NSData)
            self.delegate?.updateCellImage(data as Data)
            return data
        } catch {
            self.delegate?.updateCellImage(nil)
            return nil
        }
    }
}
