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
    private var dataManager = DataManager.shared
    private var currentFilter: DigimonFilterOption!
    private var digimonNotFoundView = DigimonNotFoundView()

    private struct Constants {
        static let sidesMargin: CGFloat = 15
    }

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
        searchBar.enablesReturnKeyAutomatically = false;
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)))
        dataManager.delegate = self
        setupStackView()
    }

    private func setupStackView() {
        view.addSubview(stackView)

        setupSearchBar()
        setupSegmentedControl()
        setupTableView()
        setupDigimonNotFoundView()
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

    private func setupDigimonNotFoundView() {
        stackView.addArrangedSubview(digimonNotFoundView)
        digimonNotFoundView.isHidden = true
    }

    private func setupTableView() {
        stackView.addArrangedSubview(digimonTableView)

        digimonTableView.register(DigimonTableViewCell.self, forCellReuseIdentifier: "cell")
        digimonTableView.delegate = self
        digimonTableView.dataSource = self

        getAllDigimon()
    }

    @objc private func indexChanged(_ sender: UISegmentedControl) {
        currentFilter = DigimonFilterOption.allCases[segmentedControl.selectedSegmentIndex]
        searchBar.placeholder = "Filter by \(currentFilter.rawValue)"
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func getAllDigimon() {
        dataManager.getAllDigimon()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sidesMargin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sidesMargin),
        ])
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataManager.digimons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DigimonTableViewCell else {
            return UITableViewCell()
        }

        cell.configureCell(with: dataManager.digimons[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Add details screen
    }
}

extension MainViewController: MainViewProtocol {
    func showDigimons() {
        digimonTableView.reloadData()
        digimonTableView.isHidden = false
        digimonNotFoundView.isHidden = true
    }

    func showErrorScreen() {
        digimonTableView.isHidden = true
        digimonNotFoundView.isHidden = false
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterWith(by: currentFilter, with: searchBar.text)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            getAllDigimon()
        }
    }

    private func filterWith(by filter: DigimonFilterOption, with text: String?) {
        guard let text, !text.isEmpty else {
            return
        }
        switch filter {
            case .name:
                filterBy(name: text)
            case .level:
                filterBy(level: text)
        }
    }

    private func filterBy(name: String) {
        dataManager.getDigimonsFilteredBy(name: name)
    }

    private func filterBy(level: String) {
        dataManager.getDigimonsFilteredBy(level: level)
    }
}
