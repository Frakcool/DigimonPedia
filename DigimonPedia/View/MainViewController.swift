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
    private let viewModel: MainViewViewModelProtocol
    private let digimonNotFoundView = DigimonNotFoundView()

    private var currentFilter: DigimonFilterOption?

    private struct Constants {
        static let reuseIdentifier = "cell"
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

    private let purgeCoreDataButton: UIButton = {
        let button = UIButton()
        button.setTitle("Purge Cache", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    init(viewModel: MainViewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)))
        viewModel.delegate = self
        setupStackView()
    }

    private func setupStackView() {
        view.addSubview(stackView)

        setupSearchBar()
        setupSegmentedControl()
        setupTableView()
        setupPurgeCoreDataButton()
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
        segmentedControl.sendActions(for: .valueChanged) // Triggers indexChanged so that placeholder for searchBar is updated
    }

    private func setupDigimonNotFoundView() {
        stackView.addArrangedSubview(digimonNotFoundView)
        digimonNotFoundView.isHidden = true
    }

    private func setupTableView() {
        stackView.addArrangedSubview(digimonTableView)

        digimonTableView.register(DigimonTableViewCell.self, forCellReuseIdentifier: MainViewController.Constants.reuseIdentifier)
        digimonTableView.delegate = self
        digimonTableView.dataSource = self

        Task {
            await getAllDigimon()
        }
    }

    private func setupPurgeCoreDataButton() {
        stackView.addArrangedSubview(purgeCoreDataButton)
        let tap = UITapGestureRecognizer(target: self, action: #selector(purgeButtonPressed))
        tap.numberOfTapsRequired = 2
        purgeCoreDataButton.addGestureRecognizer(tap)
    }

    @objc private func indexChanged(_ sender: UISegmentedControl) {
        currentFilter = DigimonFilterOption.allCases[segmentedControl.selectedSegmentIndex]
        searchBar.placeholder = "Filter by \(currentFilter?.rawValue ?? "Name")"
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func purgeButtonPressed() {
        viewModel.purgeCache()
    }

    private func getAllDigimon() async {
        await viewModel.getAllDigimon()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sidesMargin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sidesMargin),
        ])
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.digimons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewController.Constants.reuseIdentifier, for: indexPath) as? DigimonTableViewCell else {
            return UITableViewCell()
        }

        let digimonViewModel = DigimonViewModel(digimon: viewModel.digimons[indexPath.row], persistentCacheManager: viewModel.persistentCacheManager)
        cell.configureCell(with: digimonViewModel)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Add details screen
    }
}

extension MainViewController: MainViewModelDelegate {
    func showDigimons() {
        DispatchQueue.main.async {
            self.digimonTableView.reloadData()
            self.digimonTableView.isHidden = false
            self.digimonNotFoundView.isHidden = true
        }
    }

    func showErrorScreen() {
        DispatchQueue.main.async {
            self.digimonTableView.isHidden = true
            self.digimonNotFoundView.isHidden = false
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            await filterWith(by: currentFilter, with: searchBar.text)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            Task {
                await getAllDigimon()
            }
        }
    }

    private func filterWith(by filter: DigimonFilterOption?, with text: String?) async {
        guard let text, !text.isEmpty, filter != nil else {
            return
        }
        switch filter {
            case .name:
                await filterBy(name: text)
            case .level:
                await filterBy(level: text)
            case .none:
                return
        }
    }

    private func filterBy(name: String) async {
        await viewModel.getDigimonsFilteredBy(name: name)
    }

    private func filterBy(level: String) async {
        await viewModel.getDigimonsFilteredBy(level: level)
    }
}
