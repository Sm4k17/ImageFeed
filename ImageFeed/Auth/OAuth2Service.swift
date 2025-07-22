//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 16.07.2025.
//

import Foundation

final class OAuth2Service {
    // MARK: - Singleton
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    private let networkClient = NetworkClient()
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard lastCode != code else { return }
        lastCode = code
        
        networkClient.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.lastCode = nil
                completion(result)
            }
        }
    }
}
