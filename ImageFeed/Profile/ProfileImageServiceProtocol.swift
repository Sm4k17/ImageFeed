//
//  ProfileImageServiceProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func clearAvatarURL()
}
