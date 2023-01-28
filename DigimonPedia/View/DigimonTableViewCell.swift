//
//  DigimonTableViewCell.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import UIKit

class DigimonTableViewCell: UITableViewCell {
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

    private var nameLabel: UILabel = { // TODO: Add a better font
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
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

    func configureCell(with digimon: Digimon) {
        nameLabel.text = digimon.name
        updateImage(of: digimon)
    }

    private func updateImage(of digimon: Digimon) {
        NetworkManager.shared.getImage(from: digimon.img) { data, error in
            if let error {
                print("Error \(error)") // TODO: Handle no image case
            }

            if let data {
                self.digimonImage.image = UIImage(data: data)
            }
        }
    }

    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(digimonImage)
        stackView.addArrangedSubview(nameLabel)

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
