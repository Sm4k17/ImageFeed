//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false
    var lastRequest: URLRequest?
    var setProgressValueCalled = false
    var lastProgressValue: Float?
    var setProgressHiddenCalled = false
    var lastProgressHidden: Bool?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        lastRequest = request
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
        lastProgressValue = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
        lastProgressHidden = isHidden
    }
}
