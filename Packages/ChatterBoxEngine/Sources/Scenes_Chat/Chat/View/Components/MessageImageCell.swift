//
//  MessageImageCell.swift
//
//
//  Created by Dmytro Vorko on 23/07/2024.
//

import UIKit
import ImageCacheKit
import Extensions

struct MessageImageCellModel: Hashable {
    let id: String
    let imageURLs: [String]
    let isOutput: Bool
    let imageModels: [ImageCellModel]
    
    init(id: String, imageURLs: [String], menuInteractions: [MenuInteractionAction], isOutput: Bool) {
        self.id = id
        self.imageURLs = imageURLs
        self.isOutput = isOutput
        self.imageModels = imageURLs.map {
            ImageCellModel(imageURL: $0, isOutput: isOutput, menuInteractions: menuInteractions)
        }
    }
}

extension MessageImageCellModel {
    func getImages(
        cacher: ImageCacherProtocol,
        onUpdate: @escaping ((url: String, image: UIImage)) -> Void
    ) -> Task<(), Never>? {
        let urls = imageURLs.compactMap { URL(string: $0) }
        guard !urls.isEmpty else {
            return nil
        }
        return Task {
            for url in urls {
                guard let image = await cacher.getImage(from: url) else {
                    continue
                }
                guard !Task.isCancelled else { return }
                DispatchQueue.main.async {
                    onUpdate((url: url.absoluteString, image: image))
                }
            }
        }
    }
}

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
