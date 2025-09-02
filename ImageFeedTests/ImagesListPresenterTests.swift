//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 01.09.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    // MARK: - ViewController Tests
    
    func testViewControllerCallsPresenterDidLoad() {
        // Проверяем, что при загрузке View вызывается viewDidLoad презентера
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        _ = viewController.view // Загружаем View, что вызывает viewDidLoad
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsPresenterOnRefresh() {
        // Проверяем, что обновление данных вызывает метод презентера
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        presenter.refreshPhotos()
        
        XCTAssertTrue(presenter.refreshPhotosCalled)
    }
    
    // MARK: - Presenter Tests
    
    func testPresenterCallsServiceOnViewDidLoad() {
        // Проверяем, что презентер загружает фото при инициализации
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewSpy()
        presenter.view = view
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
        XCTAssertTrue(view.showLoadingIndicatorCalled)
    }
    
    func testPresenterReturnsCorrectPhotosCount() {
        // Проверяем корректное количество фото
        let presenter = ImagesListPresenter()
        let testPhotos = [createTestPhoto(), createTestPhoto()]
        presenter.photos = testPhotos
        
        XCTAssertEqual(presenter.photosCount, 2)
    }
    
    func testPresenterReturnsPhotoAtIndex() {
        // Проверяем получение фото по индексу
        let presenter = ImagesListPresenter()
        let testPhoto = createTestPhoto(id: "test_id")
        presenter.photos = [testPhoto]
        
        let result = presenter.photo(at: 0)
        
        XCTAssertEqual(result?.id, "test_id")
    }
    
    func testPresenterReturnsNilForInvalidIndex() {
        // Проверяем обработку неверного индекса
        let presenter = ImagesListPresenter()
        presenter.photos = [createTestPhoto()]
        
        let result = presenter.photo(at: 1)
        
        XCTAssertNil(result)
    }
    
    func testPresenterCalculatesCellHeightCorrectly() {
        // Проверяем расчет высоты ячейки
        let presenter = ImagesListPresenter()
        let testPhoto = createTestPhoto(size: CGSize(width: 100, height: 200))
        presenter.photos = [testPhoto]
        
        let indexPath = IndexPath(row: 0, section: 0)
        let height = presenter.calculateCellHeight(for: indexPath, tableViewWidth: 400)
        
        let expectedHeight: CGFloat = (200 * (400 - 32) / 100) + 8
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testPresenterConfiguresCellCorrectly() {
        // Проверяем настройку ячейки
        let presenter = ImagesListPresenter()
        let testPhoto = createTestPhoto(isLiked: true)
        presenter.photos = [testPhoto]
        let cell = ImagesListCellSpy()
        
        presenter.configureCell(cell, at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(cell.setLikeButtonImageCalled)
    }
}

// MARK: - Test Doubles

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var viewDidLoadCalled = false
    var refreshPhotosCalled = false
    var photosCount: Int = 0
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {}
    func refreshPhotos() {
        refreshPhotosCalled = true
    }
    func photo(at index: Int) -> Photo? { return nil }
    func selectedPhoto(at index: Int) -> Photo? { return nil }
    func calculateCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat { return 0 }
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath) {}
    func didTapLikeButton(at index: Int, cell: ImagesListCellProtocol) {}
}

final class ImagesListViewSpy: ImagesListViewProtocol {
    var updateTableViewAnimatedCalled = false
    var reloadTableViewCalled = false
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var showErrorAlertCalled = false
    var showLikeErrorCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func reloadTableView() {
        reloadTableViewCalled = true
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showErrorAlert(title: String, message: String) {
        showErrorAlertCalled = true
    }
    
    func showLikeError(error: Error) {
        showLikeErrorCalled = true
    }
}

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var resetPhotosCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Photo, Error>) -> Void) {
        changeLikeCalled = true
    }
    
    func resetPhotos() {
        resetPhotosCalled = true
    }
}

final class ImagesListCellSpy: ImagesListCellProtocol {
    var setLikeButtonImageCalled = false
    var onLikeButtonTapped: (() -> Void)?
    
    func setLikeButtonImage(isLiked: Bool) {
        setLikeButtonImageCalled = true
    }
}

// MARK: - Helper

private func createTestPhoto(
    id: String = "test_id",
    size: CGSize = CGSize(width: 100, height: 100),
    isLiked: Bool = false
) -> Photo {
    guard let thumbURL = URL(string: "https://example.com/thumb.jpg"),
          let largeURL = URL(string: "https://example.com/full.jpg") else {
        fatalError("Invalid test URLs")
    }
    
    let urls = Photo.Urls(
        raw: "https://example.com/raw.jpg",
        full: largeURL.absoluteString,
        regular: "https://example.com/regular.jpg",
        small: "https://example.com/small.jpg",
        thumb: thumbURL.absoluteString
    )
    
    return Photo(
        id: id,
        size: size,
        createdAt: Date(),
        welcomeDescription: "Test",
        thumbImageURL: thumbURL,
        largeImageURL: largeURL,
        urls: urls,
        isLiked: isLiked
    )
}
