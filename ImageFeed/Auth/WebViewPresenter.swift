//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.08.2025.
//

import Foundation

// MARK: - WebViewPresenter
final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Properties
    weak var view: WebViewViewControllerProtocol?
    private let authConfiguration: AuthConfiguration
    
    // MARK: - Initialization
    init(authConfiguration: AuthConfiguration = .standard) {
        self.authConfiguration = authConfiguration
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard let request = AuthHelper.makeAuthRequest(authConfiguration: authConfiguration) else {
            print("Invalid auth request")
            return
        }
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progressValue = Float(newValue)
        view?.setProgressValue(progressValue)
        view?.setProgressHidden(isProgressComplete(newValue))
    }
    
    // MARK: - Private Methods
    private func isProgressComplete(_ progress: Double) -> Bool {
        abs(progress - 1.0) <= 0.0001
    }
}
