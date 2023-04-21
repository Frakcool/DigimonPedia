//
//  DigimonNotFoundView.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 27/01/23.
//

import UIKit

class DigimonNotFoundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(label)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Digimon not found"
        label.font = UIFont(name: "Futura", size: 36)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let imageView: UIImageView = {
        let image = UIImage(named: "keramon2")
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            imageView.heightAnchor.constraint(equalToConstant: 500),

            label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 50),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
