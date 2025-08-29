//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updateProfileDetailsCalled = false
    var lastProfileName: String?
    var lastProfileLoginName: String?
    var lastProfileBio: String?
    var setDefaultProfileValuesCalled = false
    var updateAvatarCalled = false
    var lastAvatarURL: URL?
    var showLogoutConfirmationCalled = false
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        lastProfileName = name
        lastProfileLoginName = loginName
        lastProfileBio = bio
    }
    
    func setDefaultProfileValues() {
        setDefaultProfileValuesCalled = true
    }
    
    func updateAvatar(with url: URL?) {
        updateAvatarCalled = true
        lastAvatarURL = url
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
}
