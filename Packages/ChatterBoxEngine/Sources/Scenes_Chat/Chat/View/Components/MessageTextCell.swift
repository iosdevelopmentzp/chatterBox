//
//  MessageTextCell.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

final class MessageTextCell: UICollectionViewCell {
    // MARK: - UI Components
    
    private let contentContainer = UIView(frame: .zero)
    private let textLabel = UILabel(frame: .zero)
    private let messageContainer = UIView()
    
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
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(messageContainer)
        messageContainer.addSubview(textLabel)
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            /* contentContainer */
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            /* messageContainer */
            messageContainer.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 8),
            messageContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 8),
            messageContainer.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -8),
            
            /* textLabel */
            textLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -8),
            textLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -8)
        ])
        
        // Create a width constraint that is less than or equal to 70% of contentContainer's width
        let maxWidthConstraint = messageContainer.widthAnchor.constraint(lessThanOrEqualTo: contentContainer.widthAnchor, multiplier: 0.8)
        maxWidthConstraint.priority = UILayoutPriority(rawValue: 999)
        maxWidthConstraint.isActive = true
    }
    
    private func setupViews() {
        textLabel.numberOfLines = 0
        
        contentContainer.backgroundColor = .lightGray
        
        messageContainer.backgroundColor = .systemBlue
        messageContainer.layer.cornerRadius = 15
        messageContainer.clipsToBounds = true
        
        contentView.backgroundColor = .blue
    }
    
    // MARK: - Configure
    
    func configure(model: MessageTextCellModel) {
        self.textLabel.text = model.message
    }
}
