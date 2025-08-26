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
        formatter.doesRelativeDateFormatting = false
        return formatter
    }()
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageSizes: [CGSize] = []
    private let refreshControl = UIRefreshControl()
    
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
        setupRefreshControl()
        setupNotificationObserver()
        fetchInitialPhotos()
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
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
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .ypWhite
        refreshControl.addTarget(self, action: #selector(refreshPhotos(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
    
    // MARK: - Action Methods
    @objc private func refreshPhotos(_ sender: Any) {
        photos.removeAll()
        imageSizes.removeAll()
        tableView.reloadData()
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func handlePhotosChanged(_ notification: Notification) {
        let newPhotos = imagesListService.photos
        
        // Проверяем, что новые фотографии действительно новые
        if newPhotos.count > photos.count {
            updateTableViewAnimated()
        } else if newPhotos.count < photos.count {
            // Это случай pull-to-refresh
            photos = newPhotos
            imageSizes = newPhotos.map { $0.size }
            tableView.reloadData()
        }
        
        UIBlockingProgressHUD.dismiss()
        refreshControl.endRefreshing()
    }
    
    @objc private func didTapLikeButton(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ImagesListCell,
              let indexPath = tableView.indexPath(for: cell),
              indexPath.row < photos.count else {
            return
        }
        
        var photo = photos[indexPath.row]
        let newLikeStatus = !photo.isLiked
        
        // Оптимистичное обновление
        photo.isLiked = newLikeStatus
        photos[indexPath.row] = photo
        cell.setLikeButtonImage(isLiked: newLikeStatus)
        cell.likeButton.isUserInteractionEnabled = false
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                cell.likeButton.isUserInteractionEnabled = true
                
                switch result {
                case .success(let updatedPhoto):
                    if let index = self.photos.firstIndex(where: { $0.id == updatedPhoto.id }) {
                        self.photos[index] = updatedPhoto
                    }
                case .failure(let error):
                    // Откатываем изменения
                    photo.isLiked = !newLikeStatus
                    self.photos[indexPath.row] = photo
                    cell.setLikeButtonImage(isLiked: !newLikeStatus)
                    self.showLikeErrorAlert(error: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains { $0.id == newPhoto.id }
        }
        
        if !uniqueNewPhotos.isEmpty {
            photos.append(contentsOf: uniqueNewPhotos)
            
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
        
        // Начальная настройка ячейки с placeholder
        cell.cellImage.contentMode = .center
        let placeholderImage = UIImage(named: "stab_icon")
        cell.cellImage.image = placeholderImage
        
        // Настройка загрузки изображения с использованием placeholder из Kingfisher
        cell.cellImage.kf.setImage(
            with: URL(string: photo.urls.regular),
            placeholder: placeholderImage, // Используем placeholder через Kingfisher
            options: [
                .transition(.fade(0.3)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .keepCurrentImageWhileLoading // Важная опция - сохраняет текущее изображение во время загрузки
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // После успешной загрузки меняем режим отображения
                cell.cellImage.contentMode = .scaleAspectFill
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                // При ошибке оставляем placeholder по центру
                cell.cellImage.contentMode = .center
                cell.cellImage.image = placeholderImage
            }
        }
        
        // Настройка остальных элементов ячейки
        cell.setLikeButtonImage(isLiked: photo.isLiked)
        cell.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        cell.dateLabel.text = photo.createdAt.map { ImagesListConstants.dateFormatter.string(from: $0) }
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
    
    private func showLikeErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось изменить лайк: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
