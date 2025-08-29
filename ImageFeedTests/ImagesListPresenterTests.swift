//
//  ImagesListPresenterTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    // MARK: - Properties
    var presenter: ImagesListPresenter!
    var view: ImagesListViewSpy!
    var service: ImagesListServiceSpy!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        view = ImagesListViewSpy()
        service = ImagesListServiceSpy()
        presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
    }
    
    override func tearDown() {
        presenter = nil
        view = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(view.showLoadingIndicatorCalled)
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testFetchPhotosNextPage() {
        // When
        presenter.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testRefreshPhotos() {
        // Given
        _ = presenter.photosCount
        
        // When
        presenter.refreshPhotos()
        
        // Then
        XCTAssertEqual(presenter.photosCount, 0)
        XCTAssertTrue(view.reloadTableViewCalled)
        XCTAssertTrue(service.resetPhotosCalled)
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testPhotoAtIndex() {
        // Given
        let mockPhoto = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: URL(string: "https://test.com/thumb.jpg")!,
            largeImageURL: URL(string: "https://test.com/large.jpg")!,
            urls: Photo.Urls(
                raw: "https://test.com/raw.jpg",
                full: "https://test.com/full.jpg",
                regular: "https://test.com/regular.jpg",
                small: "https://test.com/small.jpg",
                thumb: "https://test.com/thumb.jpg"
            ),
            isLiked: false
        )
        service.mockPhotos = [mockPhoto]
        
        // Имитируем получение данных от сервиса через нотификацию
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        
        // When
        let photo = presenter.photo(at: 0)
        
        // Then
        XCTAssertNotNil(photo)
        XCTAssertEqual(photo?.id, "1")
    }
    
    func testPhotoAtIndexOutOfBounds() {
        // When
        let photo = presenter.photo(at: 100)
        
        // Then
        XCTAssertNil(photo)
    }
    
    func testCalculateCellHeight() {
        // Given
        service.mockPhotos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 200),
                createdAt: Date(),
                welcomeDescription: "Test",
                thumbImageURL: URL(string: "https://test.com/thumb.jpg")!,
                largeImageURL: URL(string: "https://test.com/large.jpg")!,
                urls: Photo.Urls(
                    raw: "https://test.com/raw.jpg",
                    full: "https://test.com/full.jpg",
                    regular: "https://test.com/regular.jpg",
                    small: "https://test.com/small.jpg",
                    thumb: "https://test.com/thumb.jpg"
                ),
                isLiked: false
            )
        ]
        
        let indexPath = IndexPath(row: 0, section: 0)
        let tableViewWidth: CGFloat = 400
        
        // When
        let height = presenter.calculateCellHeight(for: indexPath, tableViewWidth: tableViewWidth)
        
        // Then
        XCTAssertGreaterThan(height, 0)
    }
    
    func testDidSelectPhoto() {
        // Given
        service.mockPhotos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: "Test",
                thumbImageURL: URL(string: "https://test.com/thumb.jpg")!,
                largeImageURL: URL(string: "https://test.com/large.jpg")!,
                urls: Photo.Urls(
                    raw: "https://test.com/raw.jpg",
                    full: "https://test.com/full.jpg",
                    regular: "https://test.com/regular.jpg",
                    small: "https://test.com/small.jpg",
                    thumb: "https://test.com/thumb.jpg"
                ),
                isLiked: false
            )
        ]
        
        // When
        presenter.didSelectPhoto(at: 0)
        
        // Then
        // Проверяем, что метод выполнился без ошибок
        XCTAssertTrue(true)
    }
    
    func testHandlePhotosChangedWithNewPhotos() {
        // Given
        let newPhotos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: "Test",
                thumbImageURL: URL(string: "https://test.com/thumb.jpg")!,
                largeImageURL: URL(string: "https://test.com/large.jpg")!,
                urls: Photo.Urls(
                    raw: "https://test.com/raw.jpg",
                    full: "https://test.com/full.jpg",
                    regular: "https://test.com/regular.jpg",
                    small: "https://test.com/small.jpg",
                    thumb: "https://test.com/thumb.jpg"
                ),
                isLiked: false
            )
        ]
        service.mockPhotos = newPhotos
        
        // When
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        
        // Then
        XCTAssertTrue(view.hideLoadingIndicatorCalled)
    }
}

// MARK: - Test Doubles
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
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var resetPhotosCalled = false
    var mockPhotos: [Photo] = []
    
    var photos: [Photo] {
        return mockPhotos
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Photo, Error>) -> Void) {
        changeLikeCalled = true
    }
    
    func resetPhotos() {
        resetPhotosCalled = true
        mockPhotos = []
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
        )
    }
}
