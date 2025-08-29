//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var updateAvatarCalled = false
    var performLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func performLogout() {
        performLogoutCalled = true
    }
}
