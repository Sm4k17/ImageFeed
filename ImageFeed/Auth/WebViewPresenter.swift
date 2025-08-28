//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.08.2025.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authConfiguration: AuthConfiguration
    
    init(authConfiguration: AuthConfiguration = .standard) {
        self.authConfiguration = authConfiguration
    }
    
    func viewDidLoad() {
        guard let request = URLHelper.makeAuthRequest(authConfiguration: authConfiguration) else {
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
    
    private func isProgressComplete(_ progress: Double) -> Bool {
        abs(progress - 1.0) <= 0.0001
    }
}
