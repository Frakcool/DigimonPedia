//
//  MainViewController.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 23/01/23.
//

import UIKit

class MainViewController: UIViewController {
    private var digimons: [Digimon] = []

    let digimonTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTableView()
        setupConstraints()
        populateTable()
    }

    private func populateTable() {
        NetworkManager.shared.fetchAllDigimon { digimons, error in
            if let error {
                print("Error \(error)") // TODO: Add error screen
            }

            if let digimons {
                self.digimons = digimons
                self.digimonTableView.reloadData()
            }
        }
    }

    private func setupTableView() {
        self.view.addSubview(digimonTableView)

        digimonTableView.register(DigimonTableViewCell.self, forCellReuseIdentifier: "cell")
        digimonTableView.delegate = self
        digimonTableView.dataSource = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            digimonTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            digimonTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            digimonTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            digimonTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        digimons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DigimonTableViewCell else {
            return UITableViewCell()
        }

        cell.configureCell(with: digimons[indexPath.row])
        return cell
    }
}
