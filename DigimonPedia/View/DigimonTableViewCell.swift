//
//  DigimonTableViewCell.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import UIKit

class DigimonTableViewCell: UITableViewCell {
    private var digimon: Digimon?

    private struct Constants {
        static let sidesMargin: CGFloat = 15
        static let imageSize: CGFloat = 100
    }

    private var digimonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return imageView
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = UIFont(name: "Futura", size: 24)
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var levelLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = UIFont(name: "Futura", size: 16)
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(with viewModel: DigimonViewModel) {
        self.digimon = viewModel.digimon
        viewModel.delegate = self
        
        nameLabel.text = digimon?.name
        levelLabel.text = digimon?.level
        updateImage(viewModel: viewModel)
    }

    private func updateImage(viewModel: DigimonViewModel) {
        print("About to get image of \(String(describing: digimon?.name))")
        viewModel.fetchImage { [weak self] data in
            guard let self else {
                return
            }

            guard self.digimon?.img == viewModel.digimon.img else {
                // We need to return here because the cell is supposed to be showing another digimon
                return
            }

            DispatchQueue.main.async {
                self.digimonImage.image = UIImage(data: data)
            }
        }
    }

    private func setupTextStackView() {
        stackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(levelLabel)
    }

    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(digimonImage)
        setupTextStackView()

        setupConstraints()
    }

    private func setupConstraints() {
        let digimonImageHeightConstraint = digimonImage.heightAnchor.constraint(equalToConstant: Constants.imageSize)
        digimonImageHeightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sidesMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sidesMargin),

            digimonImage.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            digimonImageHeightConstraint,
        ])
    }
}

extension DigimonTableViewCell: DigimonTableViewCellDelegate {
    func updateCellImage(_ image: Data?) {
        DispatchQueue.main.async {
            guard let image else {
                self.digimonImage.image = UIImage(named: "broken_image")
                return
            }
            self.digimonImage.image = UIImage(data: image)
        }
    }
}
