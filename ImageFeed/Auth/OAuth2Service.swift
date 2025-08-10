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
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        var isCompletionCalled = false
        let safeCompletion: (Result<String, Error>) -> Void = { result in
            guard !isCompletionCalled else { return }
            isCompletionCalled = true
            
            if case .failure(let error) = result {
                print("[OAuth2Service][fetchAuthToken] Failed with error: \(error.localizedDescription), code: \(code)")
            }
            
            completion(result)
        }
        
        if let lastCode = lastCode, lastCode == code, currentTask != nil {
            safeCompletion(.failure(NetworkClient.NetworkError.duplicateRequest))
            return
        }
        
        currentTask?.cancel()
        currentTask = nil
        lastCode = code
        
        currentTask = networkClient.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.currentTask = nil
                self?.lastCode = nil
                safeCompletion(result)
            }
        }
        
        if currentTask == nil {
            safeCompletion(.failure(NetworkClient.NetworkError.invalidRequest))
        }
    }
}
