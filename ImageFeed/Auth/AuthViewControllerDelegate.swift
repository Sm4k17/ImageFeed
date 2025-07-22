//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 09.07.2025.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}
