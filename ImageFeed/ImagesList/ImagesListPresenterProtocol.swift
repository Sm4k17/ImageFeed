//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func refreshPhotos()
    func photo(at index: Int) -> Photo? // Добавляем этот метод
    func calculateCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    func didSelectPhoto(at index: Int)
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath)
    func didTapLikeButton(at index: Int, cell: ImagesListCell)
}
