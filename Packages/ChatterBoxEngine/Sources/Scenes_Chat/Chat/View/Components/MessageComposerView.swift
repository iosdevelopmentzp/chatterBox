//
//  MessageComposerView.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

final class MessageComposerView: UIView {
    // MARK: - Nested
    
    enum Event {
        case didTapSendButton
        case didTapAttachButton
        case textDidChange(String)
    }
    
    // MARK: - UI Components
    
    private let stackView = UIStackView(frame: .zero)
    private let textField = UITextField(frame: .zero)
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)
    private let topSeparator = UIView(frame: .zero)
    private let bottomSeparator = UIView(frame: .zero)
    
    // MARK: - Handlers
    
    var onEvent: ((Event) -> Void)?
    
    // MARK: - Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupComponentsUserInteractions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(topSeparator)
        addSubview(stackView)
        addSubview(bottomSeparator)
        
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(attachButton)
        stackView.addArrangedSubview(sendButton)
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        backgroundColor = .white
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
        attachButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)

        updateSendButtonState(animated: false)
        
        topSeparator.backgroundColor = .separator
        bottomSeparator.backgroundColor = .separator
    }
    
    private func setupConstraints() {
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            /* separator */
            
            topSeparator.heightAnchor.constraint(equalToConstant: 1),
            topSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topSeparator.topAnchor.constraint(equalTo: self.topAnchor),
            
            /* stackView */
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
            bottomSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        [sendButton, attachButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            let size: CGFloat = 40
            
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: size)
            ])
            
        }
        
        sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        attachButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private func setupComponentsUserInteractions() {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        attachButton.addTarget(self, action: #selector(attachButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - User Interaction
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSendButtonState(animated: true)
        self.onEvent?(.textDidChange(textField.text ?? ""))
    }
    
    @objc private func sendButtonTapped() {
        self.onEvent?(.didTapSendButton)
    }
    
    @objc private func attachButtonTapped() {
        self.onEvent?(.didTapAttachButton)
    }
    
    // MARK: - Configure
    
    func configure(model: MessageComposerViewModel) {
        textField.placeholder = model.placeholder
        if textField.text != model.text {
            textField.text = model.text
        }
        updateSendButtonState(animated: false)
    }
    
    // MARK: - Private Functions
    
    private func updateSendButtonState(animated: Bool) {
        let isEnabled = !(self.textField.text ?? "").isEmpty
        
        let color: UIColor = isEnabled ? .systemBlue : .gray
        self.sendButton.isEnabled = isEnabled
        
        guard animated else {
            self.sendButton.setTitleColor(color, for: .normal)
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.sendButton.setTitleColor(color, for: .normal)
        }
    }
}
