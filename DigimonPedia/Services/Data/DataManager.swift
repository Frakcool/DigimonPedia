//
//  DataManager.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import Foundation

protocol MainViewProtocol {
    func showDigimons()
    func showErrorScreen()
}

class DataManager {
    static var shared = DataManager()

    var digimons: [Digimon] = []
    var delegate: MainViewProtocol?

    private init() {}

    private lazy var updateDigimons: (([Digimon]?, Error?) -> Void) = { digimons, error in
        guard error == nil, let digimons else {
            self.delegate?.showErrorScreen()
            return
        }

        self.digimons = digimons
        self.delegate?.showDigimons()
    }

    func getAllDigimon() {
        NetworkManager.shared.fetchAllDigimon { digimons, error in
            print("All digimon")
            self.updateDigimons(digimons, error)
        }
    }

    func getDigimonsFilteredBy(name: String) {
        NetworkManager.shared.searchDigimonBy(name: name) { digimons, error in
            print("Filter by name")
            self.updateDigimons(digimons, error)
        }
    }

    func getDigimonsFilteredBy(level: String) {
        NetworkManager.shared.searchDigimonBy(level: level) { digimons, error in
            print("Filter by level")
            self.updateDigimons(digimons, error)
        }
    }
}
