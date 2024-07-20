//
//  ChatViewController.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

public final class ChatViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    
    // MARK: - UI Components
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let messageComposerView = MessageComposerView(frame: .zero)
    private var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Constructor
    
    public init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupKeyboardNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotifications()
    }
    
    // MARK: - Setup
    
    private func setupConstraints() {
        view.addSubview(collectionView)
        view.addSubview(messageComposerView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        messageComposerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.messageComposerView.topAnchor),
            
            messageComposerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            messageComposerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        self.bottomConstraint = messageComposerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.bottomConstraint?.isActive = true
    }
    
    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MessageTextCell.self, forCellWithReuseIdentifier: String(describing: MessageTextCell.self))
        
        self.navigationItem.title = "Chat"
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let newConstraintValue = -keyboardHeight + self.view.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint?.constant = min(0, newConstraintValue)
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint?.constant = 0
        }
    }
    
    // MARK: - Private Functions
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            sectionIndex,
            layoutEnvironment -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.messageCellModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: MessageTextCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MessageTextCell
        let model = viewModel.messageCellModels[indexPath.row]
        cell.configure(model: model)
        return cell
    }
}

// MARK: -  UICollectionViewDelegate

extension ChatViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO: - Add logic if keyboard must get hidden at some point
    }
}
