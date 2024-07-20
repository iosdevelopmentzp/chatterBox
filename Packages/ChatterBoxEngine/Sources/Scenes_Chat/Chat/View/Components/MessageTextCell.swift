//
//  MessageTextCell.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

final class MessageTextCell: UICollectionViewCell {
    // MARK: - UI Components
    
    private let textLabel = UILabel(frame: .zero)
    
    // MARK: - Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupConstraints() {
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func setupViews() {
        textLabel.numberOfLines = 0
    }
    
    // MARK: - Configure
    
    func configure(model: MessageTextCellModel) {
        self.textLabel.text = model.message
    }
}
