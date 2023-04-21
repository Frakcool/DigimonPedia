//
//  MainViewViewModel.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import Foundation

protocol MainViewModelDelegate: AnyObject {
    func showDigimons()
    func showErrorScreen()
}

protocol MainViewViewModelProtocol: AnyObject {
    var digimons: [Digimon] { get set }
    var delegate: MainViewModelDelegate? { get set }

    func getAllDigimon() async
    func getDigimonsFilteredBy(name: String) async
    func getDigimonsFilteredBy(level: String) async
    func purgeCoreData()
}

class MainViewViewModel: MainViewViewModelProtocol {
    private let networkManager: NetworkManager?

    var digimons: [Digimon] = []
    weak var delegate: MainViewModelDelegate?

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

    func getAllDigimon() async {
        do {
            let digimons = try await networkManager?.fetchAllDigimon()
            print("All digimon")
            self.updateDigimons(digimons, nil)
        } catch {
            self.updateDigimons(nil, error)
        }
    }

    func getDigimonsFilteredBy(name: String) async {
        do {
            let digimons = try await networkManager?.searchDigimonBy(name: name)
            print("Filter by name")
            self.updateDigimons(digimons, nil)
        } catch {
            self.updateDigimons(nil, error)
        }
    }

    func getDigimonsFilteredBy(level: String) async {
        do {
            let digimons = try await networkManager?.searchDigimonBy(level: level)
            print("Filter by level")
            self.updateDigimons(digimons, nil)
        } catch {
            self.updateDigimons(nil, error)
        }
    }

    func purgeCoreData() {
        print("About to purge Core Data")
        CoreDataManager.shared.purgeCoreData()
    }
}
