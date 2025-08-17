//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 15.08.2025.
//

import Foundation

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
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
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
        let newPhotos: [Photo] = photoResults.compactMap { photoResult in
            guard !photos.contains(where: { $0.id == photoResult.id }) else {
                return nil
            }
            
            guard let thumbURL = URL(string: photoResult.urls.thumb),
                  let largeURL = URL(string: photoResult.urls.full) else {
                return nil
            }
            
            var date: Date? = nil
            if let dateString = photoResult.createdAt {
                // Используем ISO8601DateFormatter для парсинга даты
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                date = formatter.date(from: dateString)
                
                // Если не удалось распарсить, пробуем альтернативный формат
                if date == nil {
                    let altFormatter = ISO8601DateFormatter()
                    date = altFormatter.date(from: dateString)
                }
            }
            
            return Photo(
                id: photoResult.id,
                size: CGSize(width: photoResult.width, height: photoResult.height),
                createdAt: date,
                welcomeDescription: photoResult.description,
                thumbImageURL: thumbURL,
                largeImageURL: largeURL,
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
            self.photos.append(contentsOf: newPhotos)
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": self.photos]
            )
        }
    }
    
    private func handleError(_ error: Error) {
        print("Failed to fetch photos: \(error)")
        if let decodingError = error as? DecodingError {
            print("Decoding error details: \(decodingError.localizedDescription)")
        }
    }
}
