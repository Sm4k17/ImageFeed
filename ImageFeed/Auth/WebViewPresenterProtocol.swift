//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.08.2025.
//

import Foundation

protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}
