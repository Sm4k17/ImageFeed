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
    let scope: String
    let createdAt: Int
    let username: String?
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case username
        case userId = "user_id"
    }
}
