//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.07.2025.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
