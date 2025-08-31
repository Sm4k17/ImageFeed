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
        // given
        let presenter = WebViewPresenterSpy()
        let viewController = WebViewViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view // Triggers viewDidLoad
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Presenter's viewDidLoad should be called")
    }
    
    func testViewControllerCallsPresenterOnProgressChange() {
        // given
        let presenter = WebViewPresenterSpy()
        let viewController = WebViewViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        let testProgress: Double = 0.5
        viewController.presenter?.didUpdateProgressValue(testProgress)
        
        // then
        XCTAssertTrue(presenter.didUpdateProgressValueCalled, "Presenter's didUpdateProgressValue should be called")
        XCTAssertEqual(presenter.lastProgressValue, testProgress, "Progress value should match")
    }
    
    // MARK: - Presenter Tests
    
    func testPresenterCallsLoadRequestOnViewDidLoad() {
        // given
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled, "ViewController's load request should be called")
        XCTAssertNotNil(viewController.lastRequest, "Request should not be nil")
    }
    
    func testPresenterUpdatesProgressCorrectly() {
        // given
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        let testProgress: Double = 0.7
        presenter.didUpdateProgressValue(testProgress)
        
        // then
        XCTAssertTrue(viewController.setProgressValueCalled, "setProgressValue should be called")
        XCTAssertTrue(viewController.setProgressHiddenCalled, "setProgressHidden should be called")
        XCTAssertEqual(viewController.lastProgressValue, Float(testProgress), "Progress value should match")
    }
    
    func testProgressHiddenWhenComplete() {
        // given
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authConfiguration: .standard)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when - complete progress
        presenter.didUpdateProgressValue(1.0)
        
        // then
        XCTAssertTrue(viewController.setProgressHiddenCalled, "setProgressHidden should be called for complete progress")
        XCTAssertEqual(viewController.lastProgressHidden, true, "Progress should be hidden when complete")
        
        // when - almost complete progress
        viewController.setProgressHiddenCalled = false // reset
        presenter.didUpdateProgressValue(0.99999)
        
        // then
        XCTAssertTrue(viewController.setProgressHiddenCalled, "setProgressHidden should be called for almost complete progress")
        XCTAssertEqual(viewController.lastProgressHidden, true, "Progress should be hidden when almost complete")
        
        // when - incomplete progress
        viewController.setProgressHiddenCalled = false // reset
        presenter.didUpdateProgressValue(0.5)
        
        // then
        XCTAssertTrue(viewController.setProgressHiddenCalled, "setProgressHidden should be called for incomplete progress")
        XCTAssertEqual(viewController.lastProgressHidden, false, "Progress should not be hidden when incomplete")
    }
    
    // MARK: - AuthHelper Tests
    
    func testAuthHelperCreatesValidAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        
        // when
        let url = AuthHelper.makeAuthURL(authConfiguration: configuration)
        
        // then
        XCTAssertNotNil(url, "Auth URL should not be nil")
        
        if let urlString = url?.absoluteString {
            XCTAssertTrue(urlString.contains(configuration.authURLString))
            XCTAssertTrue(urlString.contains(configuration.accessKey))
            XCTAssertTrue(urlString.contains(configuration.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
            XCTAssertTrue(urlString.contains("response_type=code"))
            XCTAssertTrue(urlString.contains("scope=\(configuration.accessScope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        }
    }
    
    func testAuthHelperCreatesValidAuthRequest() {
        // given
        let configuration = AuthConfiguration.standard
        
        // when
        let request = AuthHelper.makeAuthRequest(authConfiguration: configuration)
        
        // then
        XCTAssertNotNil(request, "Auth request should not be nil")
        XCTAssertNotNil(request?.url, "Request URL should not be nil")
    }
    
    func testCodeFromURL() {
        // given
        let testCode = "test_code_123"
        let testURL = URL(string: "\(Constants.redirectURI)?code=\(testCode)")!
        
        // when
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        // then
        XCTAssertEqual(extractedCode, testCode)
    }
    
    func testAuthHelperExtractsCodeFromNativeURL() {
        // given
        let testCode = "test_auth_code_456"
        let testURLString = "https://unsplash.com/oauth/authorize/native?code=\(testCode)"
        let testURL = URL(string: testURLString)!
        
        // when
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        // then
        XCTAssertEqual(extractedCode, testCode, "Extracted code should match")
    }
    
    func testAuthHelperExtractsCodeFromGenericURL() {
        // given
        let testCode = "test_auth_code_789"
        let testURLString = "https://example.com/auth?code=\(testCode)&other=param"
        let testURL = URL(string: testURLString)!
        
        // when
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        // then
        XCTAssertEqual(extractedCode, testCode, "Extracted code should match")
    }
    
    func testAuthHelperReturnsNilForInvalidURL() {
        // given
        let testURLString = "https://example.com/no_code_here"
        let testURL = URL(string: testURLString)!
        
        // when
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        // then
        XCTAssertNil(extractedCode, "Should return nil for URL without code")
    }
    
    func testAuthHelperExtractsCodeFromURLWithMultipleParams() {
        // given
        let testCode = "test_code_multiple"
        let testURLString = "\(Constants.redirectURI)?state=123&code=\(testCode)&scope=public"
        let testURL = URL(string: testURLString)!
        
        // when
        let extractedCode = AuthHelper.extractCode(from: testURL, redirectURI: Constants.redirectURI)
        
        // then
        XCTAssertEqual(extractedCode, testCode, "Should extract code from URL with multiple parameters")
    }
    
    // MARK: - AuthConfiguration Tests
    
    func testAuthConfigurationStandardValues() {
        // given
        let standardConfig = AuthConfiguration.standard
        
        // then
        XCTAssertEqual(standardConfig.accessKey, Constants.accessKey)
        XCTAssertEqual(standardConfig.secretKey, Constants.secretKey)
        XCTAssertEqual(standardConfig.redirectURI, Constants.redirectURI)
        XCTAssertEqual(standardConfig.accessScope, Constants.accessScope)
        XCTAssertEqual(standardConfig.authURLString, Constants.unsplashAuthorizeURLString)
        XCTAssertEqual(standardConfig.tokenURLString, Constants.unsplashTokenURLString)
        XCTAssertEqual(standardConfig.defaultBaseURL, Constants.defaultBaseURL)
    }
}
