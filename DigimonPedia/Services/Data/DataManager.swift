//
//  DataManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import Foundation

protocol MainViewProtocol {
    func showDigimons(_ digimons: [Digimon])
    func showErrorScreen()
}

struct DataManager {
    static var shared = DataManager()

    var delegate: MainViewProtocol?

    private init() {}

    func getAllDigimon() {
        NetworkManager.shared.fetchAllDigimon { digimons, error in
            guard error == nil, let digimons else {
                delegate?.showErrorScreen()
                return
            }
            delegate?.showDigimons(digimons)
        }
    }

    func getDigimonsFilteredBy(name: String) {
        NetworkManager.shared.searchDigimonBy(name: name) { digimons, error in
            guard error == nil, let digimons else {
                delegate?.showErrorScreen()
                return
            }
            delegate?.showDigimons(digimons)
        }
    }

    func getDigimonsFilteredBy(level: String) {
        NetworkManager.shared.searchDigimonBy(level: level) { digimons, error in
            guard error == nil, let digimons else {
                delegate?.showErrorScreen()
                return
            }
            delegate?.showDigimons(digimons)
        }
    }
}
