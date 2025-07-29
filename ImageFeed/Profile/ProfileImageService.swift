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
            let error = NetworkClient.NetworkError.invalidRequest
            print("[ProfileImageService][fetchProfileImageURL] No token available, username: \(username)")
            completion(.failure(error))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            let error = NetworkClient.NetworkError.invalidRequest
            print("[ProfileImageService][fetchProfileImageURL] Invalid request, username: \(username)")
            completion(.failure(error))
            return
        }
        
        currentTask = networkClient.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            let imageURLResult: Result<String, Error>
            
            switch result {
            case .success(let userResult):
                let imageURL = userResult.profileImage.large
                self.avatarURL = imageURL
                imageURLResult = .success(imageURL)
            case .failure(let error):
                print("[ProfileImageService][fetchProfileImageURL] Failed with error: \(error.localizedDescription), username: \(username)")
                imageURLResult = .failure(error)
            }
            
            DispatchQueue.main.async {
                completion(imageURLResult)
            }
        }
    }
    
    func clearAvatarURL() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Data Structures
struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
