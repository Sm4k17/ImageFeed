//
//  ProfileServiceProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation

protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}
