//
//  OAuth2TokenStorageProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation

protocol OAuth2TokenStorageProtocol: AnyObject {
    var token: String? { get set }
}
