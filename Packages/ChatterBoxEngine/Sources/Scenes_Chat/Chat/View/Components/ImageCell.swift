//
//  ImageCell.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import UIKit
import Extensions

struct ImageCellModel: Hashable {
    let imageURL: String
    let isOutput: Bool
    let menuInteractions: [MenuInteractionAction]
}

final class ImageCell: UICollectionViewCell, Reusable {
    // MARK: - Properties
    
    private let container = UIView()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var model: ImageCellModel?
    
    // MARK: - Internal Properties
    
    var onMenuAction: ((MenuInteractionAction) -> Void)?

    // MARK: - Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        activityIndicator.hidesWhenStopped = true
        
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        
        self.clipsToBounds = false
    }
    
    private func setupConstraints() {
        contentView.addSubview(container)
        container.addSubview(imageView)
        container.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: self.container.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.container.centerXAnchor),
        ])
    }
    
    private func setupMenuInteractions() {
        let actions = model?.menuInteractions ?? []
        if actions.isEmpty, !self.container.interactions.isEmpty {
            interactions.forEach {
                self.removeInteraction($0)
            }
        }
        
        guard !actions.isEmpty, self.imageView.interactions.isEmpty else {
            return
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        self.container.addInteraction(interaction)
    }
    
    // MARK: - Configure
    
    func configure(with model: ImageCellModel, image: UIImage?) {
        self.model = model
        image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        imageView.image = image
        self.setupMenuInteractions()
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension ImageCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            let actions = (self?.model?.menuInteractions ?? []).map { interactionItem -> UIAction in
                UIAction(
                    title: interactionItem.title,
                    image: interactionItem.imageName.flatMap { UIImage(systemName: $0) },
                    attributes: interactionItem.attributes,
                    handler: { [weak self] _ in
                        self?.onMenuAction?(interactionItem)
                    }
                )
            }
            
            return UIMenu(title: "", children: actions)
        }
    }
}
