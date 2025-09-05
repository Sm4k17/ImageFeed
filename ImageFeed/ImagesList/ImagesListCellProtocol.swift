//
//  ImagesListCellProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 01.09.2025.
//

import Foundation

protocol ImagesListCellProtocol: AnyObject {
    func setLikeButtonImage(isLiked: Bool)
    var onLikeButtonTapped: (() -> Void)? { get set }
}
