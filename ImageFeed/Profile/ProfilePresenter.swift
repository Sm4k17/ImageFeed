//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import Foundation
import Kingfisher

// MARK: - ProfilePresenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    // MARK: - Initialization
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
         tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared,
         logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        setupNotificationObserver()
        loadProfileData()
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else {
            view?.updateAvatar(with: nil)
            return
        }
        view?.updateAvatar(with: url)
    }
    
    func performLogout() {
        logoutService.logout()
    }
    
    // MARK: - Internal Methods
    func getDisplayName(_ name: String) -> String {
        return name.isEmpty ? "Имя Фамилия" : name
    }
    
    func getDisplayBio(_ bio: String?) -> String {
        return bio ?? "Нет описания"
    }
    
    // MARK: - Private Methods
    private func loadProfileData() {
        guard let profile = profileService.profile else {
            view?.setDefaultProfileValues()
            return
        }
        
        let displayName = getDisplayName(profile.name)
        let displayBio = getDisplayBio(profile.bio)
        
        view?.updateProfileDetails(
            name: displayName,
            loginName: profile.loginName,
            bio: displayBio
        )
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAvatarChangeNotification),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleAvatarChangeNotification(_ notification: Notification) {
        updateAvatar()
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
