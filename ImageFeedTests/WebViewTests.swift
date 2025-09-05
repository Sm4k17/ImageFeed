//
//  WebViewTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    // MARK: - ViewController Tests
    
    func testViewControllerCallsPresenterDidLoad() {
        // Проверяем, что при загрузке View вызывается viewDidLoad презентера
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        
        _ = viewController.view // Загружаем View, что вызывает viewDidLoad
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // Проверяем, что презентер загружает запрос при инициализации
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.loadRequestCalled)
        XCTAssertNotNil(viewController.lastRequest)
    }
    
    func testProgressHiddenWhenComplete() {
        // Проверяем, что прогресс скрывается при завершении загрузки
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        presenter.view = viewController
        
        presenter.didUpdateProgressValue(1.0)
        
        XCTAssertTrue(viewController.setProgressHiddenCalled)
        XCTAssertEqual(viewController.lastProgressHidden, true)
    }
    
    func testProgressVisibleWhenIncomplete() {
        // Проверяем, что прогресс отображается во время загрузки
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        presenter.view = viewController
        
        presenter.didUpdateProgressValue(0.5)
        
        XCTAssertTrue(viewController.setProgressHiddenCalled)
        XCTAssertEqual(viewController.lastProgressHidden, false)
    }
    
    // MARK: - AuthHelper Tests
    
    func testAuthHelperCreatesValidAuthURL() {
        // Проверяем, что AuthHelper создает корректный URL для авторизации
        let configuration = AuthConfiguration.standard
        let url = AuthHelper.makeAuthURL(authConfiguration: configuration)
        
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains(configuration.authURLString))
        XCTAssertTrue(url!.absoluteString.contains(configuration.accessKey))
    }
    
    func testCodeFromURL() {
        // Проверяем, что AuthHelper правильно извлекает код из URL
        let testCode = "test_code_123"
        let testURL = URL(string: "\(Constants.redirectURI)?code=\(testCode)")!
        
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        XCTAssertEqual(extractedCode, testCode)
    }
}

// MARK: - Test Doubles

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false
    var lastRequest: URLRequest?
    var setProgressValueCalled = false
    var setProgressHiddenCalled = false
    var lastProgressHidden: Bool?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        lastRequest = request
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
        lastProgressHidden = isHidden
    }
}
