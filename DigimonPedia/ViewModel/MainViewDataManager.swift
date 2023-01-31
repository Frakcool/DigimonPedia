//
//  MainViewViewModel.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import Foundation

protocol MainViewDelegate {
    func showDigimons()
    func showErrorScreen()
}

class MainViewViewModel {
    private let networkManager: NetworkManager?

    var digimons: [Digimon] = []
    var delegate: MainViewDelegate?

    init() {
        networkManager = NetworkManager()
    }

    private lazy var updateDigimons: (([Digimon]?, Error?) -> Void) = { digimons, error in
        guard error == nil, let digimons else {
            self.delegate?.showErrorScreen()
            return
        }

        self.digimons = digimons
        self.delegate?.showDigimons()
    }

    func getAllDigimon() {
        networkManager?.fetchAllDigimon { digimons, error in
            print("All digimon")
            self.updateDigimons(digimons, error)
        }
    }

    func getDigimonsFilteredBy(name: String) {
        networkManager?.searchDigimonBy(name: name) { digimons, error in
            print("Filter by name")
            self.updateDigimons(digimons, error)
        }
    }

    func getDigimonsFilteredBy(level: String) {
        networkManager?.searchDigimonBy(level: level) { digimons, error in
            print("Filter by level")
            self.updateDigimons(digimons, error)
        }
    }
}
