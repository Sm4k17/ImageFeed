//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListServiceProtocol
    var photos: [Photo] = []
    var imageSizes: [CGSize] = []
    
    // Статический DateFormatter для всего класса
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = false
        return formatter
    }()
    
    var photosCount: Int {
        return photos.count
    }
    
    // MARK: - Initialization
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
        setupNotificationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view?.showLoadingIndicator()
        imagesListService.fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func refreshPhotos() {
        photos.removeAll()
        imageSizes.removeAll()
        view?.reloadTableView()
        imagesListService.resetPhotos()
        fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let imageViewWidth = tableViewWidth - 16 - 16 // Отступы слева и справа
        
        guard indexPath.row < photos.count else {
            return 200 // дефолтная высота
        }
        
        let photo = photos[indexPath.row]
        let imageSize = photo.size // Берем размер напрямую из фото
        
        guard imageSize.width > 0 else {
            return 200 // защита от деления на ноль
        }
        
        let scaleRatio = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scaleRatio
        
        return imageViewHeight + 4 + 4 // 4+4 = отступы сверху и снизу
    }
    
    func selectedPhoto(at index: Int) -> Photo? {
            return photo(at: index)
        }
    
    func didTapLikeButton(at index: Int, cell: ImagesListCellProtocol) {
        guard var photo = photo(at: index) else { return }
        
        let newLikeStatus = !photo.isLiked
        photo.isLiked = newLikeStatus
        photos[index] = photo
        cell.setLikeButtonImage(isLiked: newLikeStatus)
        // Если ячейка является ImagesListCell, отключаем кнопку
        if let imagesListCell = cell as? ImagesListCell {
            imagesListCell.likeButton.isUserInteractionEnabled = false
        }
        
        view?.showLoadingIndicator()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                // Если ячейка является ImagesListCell, включаем кнопку обратно
                if let imagesListCell = cell as? ImagesListCell {
                    imagesListCell.likeButton.isUserInteractionEnabled = true
                }
                
                switch result {
                case .success(let updatedPhoto):
                    if let index = self.photos.firstIndex(where: { $0.id == updatedPhoto.id }) {
                        self.photos[index] = updatedPhoto
                    }
                case .failure(let error):
                    photo.isLiked = !newLikeStatus
                    self.photos[index] = photo
                    cell.setLikeButtonImage(isLiked: !newLikeStatus)
                    self.view?.showLikeError(error: error)
                }
            }
        }
    }
    
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        // Используем статический форматтер
        if let cell = cell as? ImagesListCell {
            cell.dateLabel.text = photo.createdAt.map { ImagesListPresenter.dateFormatter.string(from: $0) }
        }
        cell.setLikeButtonImage(isLiked: photo.isLiked)
    }
    
    // MARK: - Private Methods
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotosChanged(_:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handlePhotosChanged(_ notification: Notification) {
        let newPhotos = imagesListService.photos
        
        if newPhotos.count > photos.count {
            updateTableViewAnimated(newPhotos: newPhotos)
        } else if newPhotos.count < photos.count {
            photos = newPhotos
            imageSizes = newPhotos.map { $0.size }
            view?.reloadTableView()
        }
        
        view?.hideLoadingIndicator()
    }
    
    private func updateTableViewAnimated(newPhotos: [Photo]) {
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains { $0.id == newPhoto.id }
        }
        
        if !uniqueNewPhotos.isEmpty {
            let oldCount = photos.count
            photos.append(contentsOf: uniqueNewPhotos)
            
            let newSizes = uniqueNewPhotos.map { $0.size }
            imageSizes.append(contentsOf: newSizes)
            
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: photos.count)
        }
    }
}
