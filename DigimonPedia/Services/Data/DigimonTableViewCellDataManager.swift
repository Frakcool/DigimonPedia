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
    // Uncomment this line and the init one and use .shared in the cell's manager definition
//    static let shared = DigimonTableViewCellDataManager()

    var image: UIImage?
    var delegate: DigimonTableViewCellProtocol?

//    private init() {}

    func getImage(from imageURLString: String) {
        NetworkManager.shared.getImage(from: imageURLString) { data, error in
            guard error == nil, let data else {
                self.image = UIImage(named: "broken_image")
                self.delegate?.updateImage()
                return
            }

            self.image = UIImage(data: data)
            self.delegate?.updateImage()
        }
    }
}
