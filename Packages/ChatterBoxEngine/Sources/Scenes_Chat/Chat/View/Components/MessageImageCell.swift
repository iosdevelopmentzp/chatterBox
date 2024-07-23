//
//  MessageImageCell.swift
//
//
//  Created by Dmytro Vorko on 23/07/2024.
//

import UIKit
import ImageCacheKit

final class MessageImagesCell: UICollectionViewCell {
    // MARK: - UI Components
    
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let contentContainer = UIView()
    
    private var isOutput = false
    
    private var imageURLs: [String] = [] {
        didSet { self.collectionView.reloadData() }
    }
    
    private var cachedImages: [String: UIImage] = [:]
    
    private var getImagesTask: Task<(), Never>? {
        willSet {
            getImagesTask?.cancel()
        }
    }
    
    private var messageTransform: CGAffineTransform {
        isOutput ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform.identity
    }
    
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
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(collectionView)
        
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with model: MessageImageCellModel, imageCacher: ImageCacherProtocol?) {
        self.collectionView.scrollToTop(animated: false)
        
        self.isOutput = model.isOutput
        self.contentContainer.transform = messageTransform
        
        guard let imageCacher else {
            self.cachedImages = [:]
            self.imageURLs = []
            self.getImagesTask = nil
            return
        }
        
        guard self.imageURLs != model.imageURLs else {
            return
        }
        self.cachedImages = [:]
        self.imageURLs = model.imageURLs
        
        self.getImagesTask = model.getImages(cacher: imageCacher, onUpdate: { [weak self] urlString, image in
            guard let self, self.imageURLs.contains(urlString) else { return }
            if let row = self.imageURLs.firstIndex(of: urlString),
               collectionView.indexPathsForVisibleItems.contains(IndexPath(row: row, section: 0)) {
                (collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ImageCell)?.configure(with: image)
            }
            
            self.cachedImages[urlString] = image
        })
    }
    
    // MARK: - Deinit
    
    deinit {
        self.getImagesTask?.cancel()
    }
}

// MARK: - UICollectionViewDataSource

extension MessageImagesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue ImageCell")
        }
        cell.transform = self.messageTransform
        cell.configure(with: self.cachedImages[imageURLs[indexPath.row]])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MessageImagesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height * 0.6, height: height)
    }
}

// MARK: - ImageCell for individual images

final class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

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
        imageView.clipsToBounds = true
    }
    
    private func setupConstraints() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
        ])
    }
    
    func configure(with image: UIImage?) {
        image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        imageView.image = image
    }
}
