//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 09.07.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    // Вызывается при успешной авторизации (получен код)
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    // Вызывается при отмене авторизации (нажата кнопка назад)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
