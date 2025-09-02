//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func refreshPhotos()
    func photo(at index: Int) -> Photo?
    func selectedPhoto(at index: Int) -> Photo?
    func calculateCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath)
    func didTapLikeButton(at index: Int, cell: ImagesListCellProtocol)
}
