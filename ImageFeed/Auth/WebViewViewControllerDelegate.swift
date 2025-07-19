//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 09.07.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
