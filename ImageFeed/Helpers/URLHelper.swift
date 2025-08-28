//
//  URLHelper.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.08.2025.
//

import Foundation
import WebKit

enum URLHelper {
    static func makeAuthURL(authConfiguration: AuthConfiguration) -> URL? {
        guard var urlComponents = URLComponents(string: authConfiguration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: authConfiguration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    static func makeAuthRequest(authConfiguration: AuthConfiguration) -> URLRequest? {
        guard let url = makeAuthURL(authConfiguration: authConfiguration) else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    static func extractCode(from navigationAction: WKNavigationAction,
                            redirectURI: String) -> String? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        return extractCode(from: url, redirectURI: redirectURI)
    }
    
    static func extractCode(from url: URL, redirectURI: String) -> String? {
        // Проверка стандартного redirect URI
        if url.absoluteString.hasPrefix(redirectURI),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        
        // Проверка native URL
        if url.absoluteString.contains("unsplash.com/oauth/authorize/native"),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        
        // Общая проверка параметра code
        if url.absoluteString.contains("code="),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        return nil
    }
}
