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
        
        guard let request = makeProfileRequest(token: token) else {
            let error = NetworkClient.NetworkError.invalidRequest
            print("[ProfileService][fetchProfile] Invalid request, token: \(token)")
            completion(.failure(error))
            return
        }
        
        currentTask = networkClient.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            let profileResult: Result<Profile, Error>
            
            switch result {
            case .success(let profileResultData):
                let profile = Profile(from: profileResultData)
                self.profile = profile
                profileResult = .success(profile)
            case .failure(let error):
                print("[ProfileService][fetchProfile] Failed with error: \(error.localizedDescription), token: \(token)")
                profileResult = .failure(error)
            }
            
            DispatchQueue.main.async {
                completion(profileResult)
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
