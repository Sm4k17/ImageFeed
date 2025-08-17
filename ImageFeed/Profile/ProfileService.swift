//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.07.2025.
//

import Foundation

final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Properties
    private(set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let networkClient = NetworkClient()
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        
        guard let request = makeProfileRequest() else {
            completion(.failure(NetworkClient.NetworkError.invalidRequest))
            return
        }
        
        currentTask = networkClient.fetch(
            ProfileResult.self,
            request: request,
            bearerToken: token
        ) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResultData):
                let profile = Profile(from: profileResultData)
                self.profile = profile
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
