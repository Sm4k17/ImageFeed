//
//  Constants.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 08.07.2025.
//

import Foundation

enum Constants {
    static let accessKey = "TE6u6IhbAwvM99QriBoYmpYaPl1X1kn8e1nCYiR83FQ"
    static let secretKey = "XAXC6FkExKorYtek7BGis2R_RIRsssTC7xyaAGqMRKE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    
}
 
enum KeychainConfig {
    static let serviceName = "com.yourapp.ImageFeed"
    static let tokenAccount = "OAuth2Token"
}
