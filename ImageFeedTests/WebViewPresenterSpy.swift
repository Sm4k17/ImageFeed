//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false
    var didUpdateProgressValueCalled = false
    var lastProgressValue: Double?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        didUpdateProgressValueCalled = true
        lastProgressValue = newValue
    }
}
