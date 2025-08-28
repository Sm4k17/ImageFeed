//
//  OAuthTokenResponse.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 19.07.2025.
//

import Foundation

struct OAuthTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String?
    let scope: String?
    let createdAt: Int?
    let username: String?
    let userId: Int?

}
