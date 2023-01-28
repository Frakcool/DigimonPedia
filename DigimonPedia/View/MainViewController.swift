//
//  MainViewController.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 23/01/23.
//

import UIKit

enum DigimonFilterOption: String, CaseIterable {
    case name = "Name"
    case level = "Level"
}

class MainViewController: UIViewController {
    private var digimons: [Digimon] = []

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: DigimonFilterOption.allCases.map{ $0.rawValue })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let digimonTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupStackView()
    }

    private func setupStackView() {
        view.addSubview(stackView)

        setupSearchBar()
        setupSegmentedControl()
        setupTableView()
        setupConstraints()
    }

    private func setupSearchBar() {
        stackView.addArrangedSubview(searchBar)
        searchBar.delegate = self
    }

    private func setupSegmentedControl() {
        stackView.addArrangedSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(MainViewController.indexChanged(_:)), for: .valueChanged)
        segmentedControl.sendActions(for: .valueChanged) // Trigger indexChanged so that placeholder for searchBar is updated
    }

    private func setupTableView() {
        stackView.addArrangedSubview(digimonTableView)

        digimonTableView.register(DigimonTableViewCell.self, forCellReuseIdentifier: "cell")
        digimonTableView.delegate = self
        digimonTableView.dataSource = self

        populateTable()
    }

    @objc private func indexChanged(_ sender: UISegmentedControl) {
        searchBar.placeholder = "Filter by \(segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "Name")"
    }

    private func populateTable() {
        DataManager.shared.delegate = self
        DataManager.shared.getAllDigimon()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("WOLOLO")
    }
}
