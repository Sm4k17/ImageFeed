//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 15.08.2025.
//

import Foundation

struct PhotoLikeResponse: Decodable {
    let photo: PhotoResult
}

final class ImagesListService {
    // MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let perPage = 10
    private let networkClient = NetworkClient()
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = tokenStorage.token else {
            print("No token available")
            return
        }
        
        guard let request = makePhotosRequest(page: nextPage, perPage: perPage) else {
            print("Invalid request")
            return
        }
        
        currentTask = networkClient.fetch(
            [PhotoResult].self,
            request: request,
            bearerToken: token
        ) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                self.processPhotos(photoResults, page: nextPage)
            case .failure(let error):
                self.handleError(error)
                print("Failed to fetch photos: \(error.localizedDescription)")
            }
            self.currentTask = nil
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else {
            completion(.failure(NetworkClient.NetworkError.duplicateRequest))
            return
        }
        
        guard let token = tokenStorage.token else {
            completion(.failure(NetworkClient.NetworkError.unauthorized))
            return
        }
        
        let httpMethod = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkClient.NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        currentTask = networkClient.fetch(PhotoLikeResponse.self, request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photoResult = response.photo
                    let updatedPhoto = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.parseDate(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: URL(string: photoResult.urls.thumb)!,
                        largeImageURL: URL(string: photoResult.urls.full)!,
                        urls: Photo.Urls(
                            raw: photoResult.urls.raw,
                            full: photoResult.urls.full,
                            regular: photoResult.urls.regular,
                            small: photoResult.urls.small,
                            thumb: photoResult.urls.thumb
                        ),
                        isLiked: photoResult.likedByUser
                    )
                    
                    DispatchQueue.main.async {
                        self.photos[index] = updatedPhoto
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self
                        )
                        completion(.success(updatedPhoto))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            self.currentTask = nil
        }
    }
    
    // MARK: - Private Methods
    private func makePhotosRequest(page: Int, perPage: Int) -> URLRequest? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        return components?.url.map { URLRequest(url: $0) }
    }
    
    private func processPhotos(_ photoResults: [PhotoResult], page: Int) {
        let newPhotos = photoResults.map { photoResult in
            Photo(
                id: photoResult.id,
                size: CGSize(width: photoResult.width, height: photoResult.height),
                createdAt: parseDate(from: photoResult.createdAt),
                welcomeDescription: photoResult.description,
                thumbImageURL: URL(string: photoResult.urls.thumb)!,
                largeImageURL: URL(string: photoResult.urls.full)!,
                urls: Photo.Urls(
                    raw: photoResult.urls.raw,
                    full: photoResult.urls.full,
                    regular: photoResult.urls.regular,
                    small: photoResult.urls.small,
                    thumb: photoResult.urls.thumb
                ),
                isLiked: photoResult.likedByUser
            )
        }
        
        DispatchQueue.main.async {
            self.lastLoadedPage = page
            
            // Добавляем только новые уникальные фото
            let uniqueNewPhotos = newPhotos.filter { newPhoto in
                !self.photos.contains { $0.id == newPhoto.id }
            }
            
            if !uniqueNewPhotos.isEmpty {
                self.photos.append(contentsOf: uniqueNewPhotos)
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
            }
        }
    }
    
    private func parseDate(from string: String?) -> Date? {
        guard let string = string else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }
    
    private func handleError(_ error: Error) {
        print("Failed to fetch photos: \(error)")
        if let decodingError = error as? DecodingError {
            print("Decoding error details: \(decodingError.localizedDescription)")
        }
    }
}
