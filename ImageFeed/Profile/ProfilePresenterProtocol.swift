//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func updateAvatar()
    func performLogout()
}
