//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 21.06.2025.
//

import UIKit

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
        static let name = "Екатерина Новикова"
        static let login = "@ekaterina_nov"
        static let description = "Hello, world!"
        static let logoutTitle = "Выход"
        static let logoutMessage = "Вы уверены, что хотите выйти?"
        static let logoutConfirm = "Да"
        static let logoutCancel = "Нет"
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
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.name
        label.font = .systemFont(ofSize: ProfileConstants.nameFontSize, weight: .bold)
        label.textColor = .ypWhite
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.login
        label.font = .systemFont(ofSize: ProfileConstants.secondaryFontSize)
        label.textColor = .ypGray
        label.accessibilityIdentifier = "loginNameLabel"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ProfileConstants.Texts.description
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileUI()
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
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: ProfileConstants.largeInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: ProfileConstants.mediumInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: ProfileConstants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            // Name
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,
                                         constant: ProfileConstants.smallInset),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                              constant: -ProfileConstants.mediumInset),
            
            // Login
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                              constant: ProfileConstants.smallInset),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor,
                                                constant: ProfileConstants.smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            
            // Logout Button
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -ProfileConstants.mediumInset),
            logoutButton.widthAnchor.constraint(equalToConstant: ProfileConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor)
        ])
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
        
        guard OAuth2TokenStorage.shared.token == nil else {
            print("Failed to delete token")
            return
        }
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                print("No window found")
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
