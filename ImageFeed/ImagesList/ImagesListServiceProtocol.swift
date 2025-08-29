//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Photo, Error>) -> Void)
    func resetPhotos()
}
