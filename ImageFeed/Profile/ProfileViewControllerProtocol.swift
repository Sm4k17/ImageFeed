//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func setDefaultProfileValues()
    func updateAvatar(with url: URL?)
    func showLogoutConfirmation()
}
