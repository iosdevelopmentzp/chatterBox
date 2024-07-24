//
//  ChatViewController.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import Combine

enum MenuInteractionAction {
    case delete
}

struct ChatViewSection: Hashable {
    // MARK: - Nested
    
    enum SectionType: Hashable {
        case main
    }
    
    struct MessageItem: Hashable {
        enum Content: Hashable {
            case textMessage(MessageTextCellModel)
            case images(model: MessageImageCellModel)
        }
        
        let id: String
        let content: Content
    }
    
    // MARK: - Proeprties
    
    let type: SectionType
    let items: [MessageItem]
}

struct ChatViewState: Hashable {
    let navigationTitle: String
    let sections: [ChatViewSection]
    let composerViewModel: MessageComposerViewModel
    let containsNewMessages: Bool
}

public final class ChatViewController: UIViewController {
    // MARK: - Nested
    
    private typealias DataSource = UICollectionViewDiffableDataSource<ChatViewSection.SectionType, ChatViewSection.MessageItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ChatViewSection.SectionType, ChatViewSection.MessageItem>
    
    private var prototypeTextCell = MessageTextCell()
    private var prototypeImageCell = MessageImagesCell()
    
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    
    private lazy var dataSource = DataSource(collectionView: collectionView) { [weak self] in
        self?.cell(for: $1, message: $2)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    private let flowLayout = UICollectionViewFlowLayout()
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
        bindViewModel()
        setupUserInteractions()
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
        collectionView.register(MessageTextCell.self, forCellWithReuseIdentifier: String(describing: MessageTextCell.self))
        collectionView.register(MessageImagesCell.self, forCellWithReuseIdentifier: String(describing: MessageImagesCell.self))
        collectionView.delegate = self
        // Apply a vertical flip transform to the collection view
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.refreshView(state: state)
            }
            .store(in: &subscriptions)
        
        self.viewModel.setupObservers(cancellations: &self.subscriptions)
    }

    // MARK: - User Interactions
    
    func setupUserInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)
        
        messageComposerView.onEvent = { [weak self] event in
            switch event {
            case .didTapSendButton:
                self?.viewModel.didTapSendButton()
                
            case .didTapAttachButton:
                self?.viewModel.didTapAttachButton()
                
            case .textDidChange(let text):
                self?.viewModel.didChangeText(text)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Notifications
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
    
    private func refreshView(state: ChatViewState) {
        /* navigation title */
        navigationItem.title = state.navigationTitle
        
        /* snapshot */
        var snapshot = Snapshot()
        snapshot.appendSections(state.sections.map(\.type))
        state.sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section.type)
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        /* messageComposerView */
        self.messageComposerView.configure(model: state.composerViewModel)
        
        /* scrollToBTop */
        if state.containsNewMessages {
            self.collectionView.scrollToTop(animated: true)
        }
    }
    
    private func cell(for indexPath: IndexPath, message: ChatViewSection.MessageItem) -> UICollectionViewCell {
        let identifier = String(describing: MessageTextCell.self)
        let returnCell: UICollectionViewCell
        switch message.content {
        case .textMessage(let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MessageTextCell
            cell.configure(model: model)
            cell.onInteractionAction = { [weak self] in
                self?.viewModel.handleMenuInteraction(action: $0, messageID: message.id)
            }
            returnCell = cell
        case .images(let model):
            let identifier = String(describing: MessageImagesCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MessageImagesCell
            cell.configure(with: model, imageCacher: viewModel.imageCacher)
            cell.onInteractionAction = {
                debugPrint($0)
            }
            returnCell = cell
        }
        
        // Apply a vertical flip transform to the cell
        returnCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return returnCell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let snapshot = self.dataSource.snapshot()
        
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let rowItem = snapshot.itemIdentifiers(inSection: section)[indexPath.row]

        let width = collectionView.frame.width
        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

        switch rowItem.content {
        case .textMessage(let model):
            prototypeTextCell.configure(model: model)
            let size = prototypeTextCell.contentView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return size
        case .images(let model):
            prototypeImageCell.configure(with: model, imageCacher: nil)
            let size = prototypeImageCell.contentView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return size
        }
    }

    private func configurePrototypeTextCell(indexPath: IndexPath) {
        // Assume `message` contains the data needed to configure the cell
        let message = dataSource.itemIdentifier(for: indexPath)
        if case let .textMessage(model) = message?.content {
            prototypeTextCell.configure(model: model)
        }
    }

    private func configurePrototypeImageCell(indexPath: IndexPath) {
        // Similarly configure based on `message`
        let message = dataSource.itemIdentifier(for: indexPath)
        if case let .images(model) = message?.content {
            prototypeImageCell.configure(with: model, imageCacher: viewModel.imageCacher)
        }
    }
}

// TODO: - move to the Extensions package
extension UICollectionView {
    /// Scrolls the collection view to the topmost item in the first section.
    func scrollToTop(animated: Bool) {
        self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }
}
