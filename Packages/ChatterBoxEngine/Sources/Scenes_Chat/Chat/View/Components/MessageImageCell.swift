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
    
    private var imageURLs: [String] = [] {
        didSet {
            guard imageURLs != oldValue else { return }
            self.collectionView.reloadData()
        }
    }
    
    private var cachedImages: [String: UIImage] = [:]
    
    private var getImagesTask: Task<(), Never>? {
        willSet {
            getImagesTask?.cancel()
        }
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
        contentView.addSubview(collectionView)
        
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with model: MessageImageCellModel, imageCacher: ImageCacherProtocol) {
        self.cachedImages = [:]
        self.imageURLs = model.imageURLs
        self.getImagesTask = model.getImages(cacher: imageCacher, onUpdate: { [weak self] urlString, image in
            self?.cachedImages[urlString] = image
            self?.collectionView.reloadData()
        })
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
        cell.configure(with: self.cachedImages[imageURLs[indexPath.row]])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MessageImagesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height, height: height) // Making square cells
    }
}

// MARK: - ImageCell for individual images

final class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        activityIndicator.hidesWhenStopped = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage?) {
        image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        imageView.image = image
    }
}
