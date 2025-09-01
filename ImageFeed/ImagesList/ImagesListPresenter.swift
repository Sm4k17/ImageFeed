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
    private var photos: [Photo] = []
    private var imageSizes: [CGSize] = []
    
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
        let imageViewWidth = tableViewWidth - 16 - 16
        
        guard indexPath.row < imageSizes.count else {
            return 200
        }
        
        let imageSize = imageSizes[indexPath.row]
        let scaleRatio = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scaleRatio
        
        return imageViewHeight + 4 + 4
    }
    
    func didSelectPhoto(at index: Int) {
        guard let photo = photo(at: index) else { return }
        
        let singleImageVC = SingleImageViewController()
        singleImageVC.imageURL = photo.largeImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        
        if let viewController = view as? UIViewController {
            viewController.present(singleImageVC, animated: true)
        }
    }
    
    func didTapLikeButton(at index: Int, cell: ImagesListCell) {
        guard var photo = photo(at: index) else { return }
        
        let newLikeStatus = !photo.isLiked
        photo.isLiked = newLikeStatus
        photos[index] = photo
        cell.setLikeButtonImage(isLiked: newLikeStatus)
        cell.likeButton.isUserInteractionEnabled = false
        
        view?.showLoadingIndicator()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                cell.likeButton.isUserInteractionEnabled = true
                
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
    
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        // Используем статический форматтер
        cell.dateLabel.text = photo.createdAt.map { ImagesListPresenter.dateFormatter.string(from: $0) }
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
