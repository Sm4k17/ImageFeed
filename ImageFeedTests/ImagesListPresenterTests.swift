//
//  ImagesListPresenterTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 01.09.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private class MockView: ImagesListViewProtocol {
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
    
    private class MockService: ImagesListServiceProtocol {
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
            photos.removeAll()
        }
    }
    
    private class MockCell: ImagesListCellProtocol {
        var setLikeButtonImageCalled = false
        var onLikeButtonTapped: (() -> Void)?
        
        func setLikeButtonImage(isLiked: Bool) {
            setLikeButtonImageCalled = true
        }
    }
    
    // MARK: - Properties
    
    private var presenter: ImagesListPresenter!
    private var mockView: MockView!
    private var mockService: MockService!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockView = MockView()
        mockService = MockService()
        presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
        XCTAssertTrue(mockView.showLoadingIndicatorCalled)
    }
    
    func testFetchPhotosNextPage() {
        // When
        presenter.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
    }
    
    func testRefreshPhotos() {
        // Given
        let photo = createTestPhoto()
        presenter.photos = [photo]
        
        // When
        presenter.refreshPhotos()
        
        // Then
        XCTAssertTrue(mockService.resetPhotosCalled)
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
        XCTAssertTrue(mockView.reloadTableViewCalled)
        XCTAssertEqual(presenter.photosCount, 0)
    }
    
    func testPhotosCount() {
        // Given
        let photos = [createTestPhoto(), createTestPhoto()]
        presenter.photos = photos
        
        // When
        let count = presenter.photosCount
        
        // Then
        XCTAssertEqual(count, 2)
    }
    
    func testPhotoAtIndex() {
        // Given
        let testPhoto = createTestPhoto()
        presenter.photos = [testPhoto]
        
        // When
        let result = presenter.photo(at: 0)
        
        // Then
        XCTAssertEqual(result?.id, testPhoto.id)
    }
    
    func testPhotoAtIndexOutOfBounds() {
        // Given
        presenter.photos = [createTestPhoto()]
        
        // When
        let result = presenter.photo(at: 1)
        
        // Then
        XCTAssertNil(result)
    }
    
    func testConfigureCell() {
        // Given
        let testPhoto = createTestPhoto()
        let mockCell = MockCell()
        presenter.photos = [testPhoto]
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        presenter.configureCell(mockCell, at: indexPath)
        
        // Then
        XCTAssertTrue(mockCell.setLikeButtonImageCalled)
    }
    
    func testCalculateCellHeight() {
        // Given
        let testPhoto = createTestPhoto(size: CGSize(width: 100, height: 200))
        presenter.photos = [testPhoto]
        presenter.imageSizes = [CGSize(width: 100, height: 200)]
        
        let tableViewWidth: CGFloat = 400
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        let height = presenter.calculateCellHeight(for: indexPath, tableViewWidth: tableViewWidth)
        
        // Then
        let expectedHeight: CGFloat = (200 * (400 - 32) / 100) + 8
        XCTAssertEqual(height, expectedHeight)
    }
    
    func testCalculateCellHeightDefault() {
        // Given
        let indexPath = IndexPath(row: 1, section: 0)
        
        // When
        let height = presenter.calculateCellHeight(for: indexPath, tableViewWidth: 400)
        
        // Then
        XCTAssertEqual(height, 200)
    }
    
    func testDidTapLikeButton() {
        // Given
        let testPhoto = createTestPhoto()
        let mockCell = MockCell()
        presenter.photos = [testPhoto]
        
        // When
        presenter.didTapLikeButton(at: 0, cell: mockCell)
        
        // Then
        XCTAssertTrue(mockService.changeLikeCalled)
        XCTAssertTrue(mockView.showLoadingIndicatorCalled)
    }
    
    // MARK: - Helper
    private func createTestPhoto(id: String = "test_id", size: CGSize = CGSize(width: 100, height: 100)) -> Photo {
        let urls = Photo.Urls(
            raw: "https://example.com/raw.jpg",
            full: "https://example.com/full.jpg",
            regular: "https://example.com/regular.jpg",
            small: "https://example.com/small.jpg",
            thumb: "https://example.com/thumb.jpg"
        )
        
        // Безопасное создание URL
        guard let thumbURL = URL(string: "https://example.com/thumb.jpg"),
              let largeURL = URL(string: "https://example.com/full.jpg") else {
            fatalError("Invalid URL in test")
        }
        
        return Photo(
            id: id,
            size: size,
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: thumbURL,
            largeImageURL: largeURL,
            urls: urls, // Добавлен недостающий параметр urls
            isLiked: false
        )
    }
}
