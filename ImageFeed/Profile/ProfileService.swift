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
        // Отменяем предыдущий запрос
        currentTask?.cancel()
        // Создаем запрос
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkClient.NetworkError.invalidRequest))
            return
        }
        // Выполняем запрос через NetworkClient
        currentTask = networkClient.fetch(request: request) { [weak self] result in
            guard let self = self else { return }
            
            var profileResult: Result<Profile, Error>
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedProfile = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(from: decodedProfile)
                    self.profile = profile
                    profileResult = .success(profile)
                } catch {
                    profileResult = .failure(error)
                }
            case .failure(let error):
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
