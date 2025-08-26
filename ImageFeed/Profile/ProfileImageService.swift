//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 28.07.2025.
//

import Foundation

final class ProfileImageService {
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Properties
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    private(set) var avatarURL: String? {
        didSet {
            guard avatarURL != oldValue else { return }
            NotificationCenter.default.post(
                name: ProfileImageService.didChangeNotification,
                object: self
            )
        }
    }
    
    private var currentTask: URLSessionTask?
    private let networkClient = NetworkClient()
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Public Methods
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        
        guard let token = tokenStorage.token else {
            completion(.failure(NetworkClient.NetworkError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(NetworkClient.NetworkError.invalidRequest))
            return
        }
        
        currentTask = networkClient.fetch(
            UserResult.self,
            request: request,
            bearerToken: token
        ) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                let imageURL = userResult.profileImage.large
                self.avatarURL = imageURL
                DispatchQueue.main.async {
                    completion(.success(imageURL))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func clearAvatarURL() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

// MARK: - Data Structures
struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Decodable {
        let small: String
        let medium: String
        let large: String
    }
}
