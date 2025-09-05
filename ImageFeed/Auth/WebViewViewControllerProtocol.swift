//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.08.2025.
//

import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
