//
//  ChatViewController.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit
import Combine
import Extensions

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
    
    private typealias DataSource = UITableViewDiffableDataSource<ChatViewSection.SectionType, ChatViewSection.MessageItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ChatViewSection.SectionType, ChatViewSection.MessageItem>
    
    private var prototypeTextCell = MessageTextCell()
    private var prototypeImageCell = MessageImagesCell()
    
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    
    private var sizesCache: [ChatViewSection.MessageItem: CGSize] = [:]
    
    private lazy var dataSource = DataSource(tableView: tableView) { [weak self] in
        self?.cell(for: $1, message: $2)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
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
        view.addSubview(tableView)
        view.addSubview(messageComposerView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageComposerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.messageComposerView.topAnchor),
            
            messageComposerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            messageComposerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        self.bottomConstraint = messageComposerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.bottomConstraint?.isActive = true
    }
    
    private func setupViews() {
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.clear
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(MessageTextCell.self, forCellReuseIdentifier: MessageTextCell.identifier)
        tableView.register(MessageImagesCell.self, forCellReuseIdentifier: MessageImagesCell.identifier)
        // Apply a vertical flip transform to the table view
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let inputImage = UIImage(systemName: "arrow.down.circle.fill")
        let outputImage = UIImage(systemName: "arrow.up.circle.fill")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: inputImage, style: .plain, target: self, action: #selector(self.leftBarButtonItemTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: outputImage, style: .plain, target: self, action: #selector(self.rightBarButtonItemTap))
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
        tableView.addGestureRecognizer(tapGesture)
        
        messageComposerView.onEvent = { [weak self] event in
            switch event {
            case .didTapSendButton:
                self?.viewModel.didTapSendButton()
                
            case .didTapAttachButton:
                self?.view.endEditing(true)
                self?.viewModel.didTapAttachButton()
                
            case .textDidChange(let text):
                self?.viewModel.didChangeText(text)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func leftBarButtonItemTap() {
        self.viewModel.didTapGenerateMessage(input: true)
    }
    
    @objc func rightBarButtonItemTap() {
        self.viewModel.didTapGenerateMessage(input: false)
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
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.bottomConstraint?.constant = min(0, newConstraintValue)
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.bottomConstraint?.constant = 0
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
            self.tableView.scrollToTop(animated: true)
        }
    }
    
    private func cell(for indexPath: IndexPath, message: ChatViewSection.MessageItem) -> UITableViewCell {
        let returnCell: UITableViewCell
        switch message.content {
        case .textMessage(let model):
            let cell = tableView.dequeueReusableCell(ofType: MessageTextCell.self, for: indexPath)
            cell.configure(model: model)
            cell.onInteractionAction = { [weak self] in
                self?.viewModel.handleMenuInteraction(action: $0, messageID: message.id)
            }
            returnCell = cell
        case .images(let model):
            let cell = tableView.dequeueReusableCell(ofType: MessageImagesCell.self, for: indexPath)
            cell.configure(with: model, imageCacher: viewModel.imageCacher)
            cell.onInteractionAction = { [weak self] in
                self?.viewModel.handleImageMenuInteraction(action: $0.action, messageID: $0.messageId, imageIndex: $0.index)
            }
            returnCell = cell
        }
        
        // Apply a vertical flip transform to the cell
        returnCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return returnCell
    }
}
