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

        // TODO: Add search bar and segmented control to enable filtering
        setupTableView()
        setupConstraints()
        populateTable()
    }

    private func populateTable() {
        DataManager.shared.delegate = self
        DataManager.shared.getAllDigimon()
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Add details screen
    }
}

extension MainViewController: MainViewProtocol {
    func showDigimons(_ digimons: [Digimon]) {
        self.digimons = digimons
        self.digimonTableView.reloadData()
    }

    func showErrorScreen() {
        print("Error")
    }
}
