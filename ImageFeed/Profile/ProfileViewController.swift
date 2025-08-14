//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 21.06.2025.
//

import UIKit
import Kingfisher

// MARK: - Constants
private enum ProfileConstants {
    static let avatarSize: CGFloat = 70
    static let buttonSize: CGFloat = 44
    static let largeInset: CGFloat = 32
    static let mediumInset: CGFloat = 16
    static let smallInset: CGFloat = 8
    static let nameFontSize: CGFloat = 23
    static let secondaryFontSize: CGFloat = 13
    
    enum Images {
        static let avatar = "avatar"
        static let logout = "logout_button"
    }
    
    enum Texts {
        static let logoutTitle = "Выход"
        static let logoutMessage = "Вы уверены, что хотите выйти?"
        static let logoutConfirm = "Да"
        static let logoutCancel = "Нет"
        static let defaultName = "Имя Фамилия"
        static let defaultLogin = "@username"
        static let defaultBio = "Нет описания"
    }
}

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "avatarImageView"
        imageView.image = UIImage(named: ProfileConstants.Images.avatar) ?? {
            let image = UIImage(systemName: "person.crop.circle.fill")
            imageView.tintColor = .ypGray
            return image
        }()
        imageView.layer.cornerRadius = ProfileConstants.avatarSize / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.defaultName
        label.font = .systemFont(ofSize: ProfileConstants.nameFontSize, weight: .bold)
        label.textColor = .ypWhite
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.defaultLogin
        label.font = .systemFont(ofSize: ProfileConstants.secondaryFontSize)
        label.textColor = .ypGray
        label.accessibilityIdentifier = "loginNameLabel"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.defaultBio
        label.font = .systemFont(ofSize: ProfileConstants.secondaryFontSize)
        label.textColor = .ypWhite
        label.accessibilityIdentifier = "descriptionLabel"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ProfileConstants.Images.logout) ??
                        UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                        for: .normal)
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "logoutButton"
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileUI()
        updateProfileDetails()
        setupNotificationObserver()
        updateAvatar()
    }
    
    // MARK: - Setup Methods
    private func setupProfileUI() {
        view.backgroundColor = .ypBlack
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: ProfileConstants.largeInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: ProfileConstants.mediumInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: ProfileConstants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,
                                           constant: ProfileConstants.smallInset),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -ProfileConstants.mediumInset),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                constant: ProfileConstants.smallInset),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor,
                                                  constant: ProfileConstants.smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -ProfileConstants.mediumInset),
            logoutButton.widthAnchor.constraint(equalToConstant: ProfileConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor)
        ])
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            setDefaultProfileValues()
            return
        }
        updateProfileUI(with: profile)
    }
    
    private func updateProfileUI(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? ProfileConstants.Texts.defaultName : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ProfileConstants.Texts.defaultBio
    }
    
    private func setDefaultProfileValues() {
        nameLabel.text = ProfileConstants.Texts.defaultName
        loginNameLabel.text = ProfileConstants.Texts.defaultLogin
        descriptionLabel.text = ProfileConstants.Texts.defaultBio
    }
    
    @objc private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        
        let targetSize = CGSize(
            width: ProfileConstants.avatarSize * UIScreen.main.scale,
            height: ProfileConstants.avatarSize * UIScreen.main.scale
        )
        
        let processor = DownsamplingImageProcessor(size: targetSize)
        |> RoundCornerImageProcessor(cornerRadius: ProfileConstants.avatarSize / 2)
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: ProfileConstants.Images.avatar),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        )
    }
    
    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: ProfileConstants.Texts.logoutTitle,
            message: ProfileConstants.Texts.logoutMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: ProfileConstants.Texts.logoutConfirm, style: .default) { [weak self] _ in
            self?.performLogout()
        })
        
        alert.addAction(UIAlertAction(title: ProfileConstants.Texts.logoutCancel, style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileImageService.shared.clearAvatarURL()
        
        let webViewVC = WebViewViewController()
        webViewVC.cleanWebViewData()
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                print("Ошибка: не найден UIWindow")
                return
            }
            
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
}
