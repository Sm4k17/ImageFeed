//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit
import Kingfisher

// MARK: - Constants
private enum ImagesListConstants {
    static let defaultCellHeight: CGFloat = 200
    static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageSizes: [CGSize] = []
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = ImagesListConstants.tableViewContentInset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNotificationObserver()
        fetchInitialPhotos()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotosChanged(_:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    private func fetchInitialPhotos() {
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Private Methods
    @objc private func handlePhotosChanged(_ notification: Notification) {
        updateTableViewAnimated()
        UIBlockingProgressHUD.dismiss()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        
        // Фильтруем только новые уникальные фото
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains { $0.id == newPhoto.id }
        }
        
        if !uniqueNewPhotos.isEmpty {
            photos.append(contentsOf: uniqueNewPhotos)
            
            // Обновляем размеры только для новых фото
            let newSizes = uniqueNewPhotos.map { $0.size }
            imageSizes.append(contentsOf: newSizes)
            
            let startIndex = oldCount
            let endIndex = photos.count - 1
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        
        // Убираем настройку индикатора
        cell.cellImage.kf.setImage(
            with: URL(string: photo.urls.regular) ?? photo.thumbImageURL,
            placeholder: UIImage(named: "stab_icon"),
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                cell.cellImage.image = UIImage(named: "load_error_icon")
            }
        }
        
        cell.dateLabel.text = photo.createdAt.map { date in
            ImagesListConstants.dateFormatter.string(from: date)
        }
        
        cell.setLikeButtonImage(isLiked: photo.isLiked)
        DispatchQueue.main.async {
            cell.setupGradient()
        }
    }
    
    private func calculateCellHeight(for indexPath: IndexPath) -> CGFloat {
        let imageViewWidth = tableView.bounds.width - ImagesListConstants.imageInsets.left - ImagesListConstants.imageInsets.right
        
        guard indexPath.row < imageSizes.count else {
            return ImagesListConstants.defaultCellHeight
        }
        
        let imageSize = imageSizes[indexPath.row]
        let scaleRatio = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scaleRatio
        
        return imageViewHeight + ImagesListConstants.imageInsets.top + ImagesListConstants.imageInsets.bottom
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateCellHeight(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.imageURL = photos[indexPath.row].largeImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
