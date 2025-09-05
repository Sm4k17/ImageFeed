//
//  ImagesListViewProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadTableView()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showErrorAlert(title: String, message: String)
    func showLikeError(error: Error)
}
