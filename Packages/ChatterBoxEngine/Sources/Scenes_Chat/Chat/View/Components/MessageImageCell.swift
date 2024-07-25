//
//  MessageImageCell.swift
//
//
//  Created by Dmytro Vorko on 23/07/2024.
//

import UIKit
import ImageCacheKit
import Extensions

final class MessageImagesCell: UITableViewCell, Reusable {
    // MARK: - Nested
    
    typealias InteractionDetails = (messageId: String, index: Int, action: MenuInteractionAction)
    
    // MARK: - UI Components
    
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let contentContainer = UIView()
    
    // MARK: - Internal Properties
    
    var onInteractionAction: ((InteractionDetails) -> Void)?
    
    // MARK: - Private Properties
    
    private var model: MessageImageCellModel? {
        didSet {
            guard model != oldValue else { return }
            self.collectionView.reloadData()
        }
    }
    
    private var getImagesTask: Task<(), Never>? {
        willSet {
            getImagesTask?.cancel()
        }
    }
    
    private var isOutput = false
    private var cachedImages: [String: UIImage] = [:]
    
    private var messageTransform: CGAffineTransform {
        isOutput ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform.identity
    }
    
    // MARK: - Constructor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(collectionView)
        
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.clipsToBounds = false
        
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.heightAnchor.constraint(equalToConstant: 200).setPriority(.init(999)),
            
            collectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
    
    // MARK: - Private
    
    private func updateCollectionView(model: MessageImageCellModel, cacher: ImageCacherProtocol?) {
        guard self.model?.imageModels != model.imageModels else {
            return
        }
        self.model = model
        
        guard let cacher else {
            self.cachedImages = [:]
            self.getImagesTask = nil
            return
        }
        
        self.cachedImages = [:]
        self.getImagesTask = model.getImages(cacher: cacher, onUpdate: { [weak self] urlString, image in
            let imageModel = self?.model?.imageModels.first(where: { $0.imageURL == urlString })
            guard let self, let imageModel else { return }
            if let row = self.model?.imageModels.firstIndex(of: imageModel),
               collectionView.indexPathsForVisibleItems.contains(IndexPath(row: row, section: 0)) {
                (collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ImageCell)?.configure(with: imageModel, image: image)
            }
            
            self.cachedImages[urlString] = image
        })
    }
    
    // MARK: - Configure
    
    func configure(with model: MessageImageCellModel, imageCacher: ImageCacherProtocol?) {
        self.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        
        self.isOutput = model.isOutput
        self.contentContainer.transform = messageTransform
        self.updateCollectionView(model: model, cacher: imageCacher)
    }
    
    // MARK: - Deinit
    
    deinit {
        self.getImagesTask?.cancel()
    }
}

// MARK: - UICollectionViewDataSource

extension MessageImagesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (model?.imageModels ?? []).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: ImageCell.self, at: indexPath)
        cell.transform = self.messageTransform
        if let cellModel = model?.imageModels[indexPath.row] {
            let cachedImage = self.cachedImages[cellModel.imageURL]
            cell.configure(with: cellModel, image: cachedImage)
            
            cell.onMenuAction = { [weak self] in
                self?.onInteractionAction?((self?.model?.id ?? "", indexPath.row, $0))
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MessageImagesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: ceil(height * 0.75), height: height)
    }
}

// MARK: - ImageCell for individual images

final class ImageCell: UICollectionViewCell, Reusable {
    private let container = UIView()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var model: ImageCellModel?
    
    var onMenuAction: ((MenuInteractionAction) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func setupMenuInteractions() {
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
    
    func configure(with model: ImageCellModel, image: UIImage?) {
        self.model = model
        image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        imageView.image = image
        self.setupMenuInteractions()
    }
}

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

struct ImageCellModel: Hashable {
    let imageURL: String
    let isOutput: Bool
    let menuInteractions: [MenuInteractionAction]
}
