//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.07.2025.
//

import UIKit

// MARK: - Constants
private enum SplashConstants {
    static let logoSize = CGSize(width: 75, height: 78)
    static let authCheckDelay: TimeInterval = 1.0
    
    enum Images {
        static let launchScreen = "LauchScreen"
    }
}

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    weak var authViewController: AuthViewController?
    
    // MARK: - UI Elements
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: SplashConstants.Images.launchScreen)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "splashLogo"
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: SplashConstants.logoSize.width),
            logoImageView.heightAnchor.constraint(equalToConstant: SplashConstants.logoSize.height)
        ])
    }
    
    // MARK: - Auth Flow
    private func checkAuthStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + SplashConstants.authCheckDelay) { [weak self] in
            guard let self else { return }
            
            if let token = self.storage.token, !token.isEmpty {
                self.fetchProfileAndSwitch(token: token)
            } else {
                self.showAuthViewController()
            }
        }
    }
    
    private func showAuthViewController() {
        let authVC = AuthViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        
        let navigationController = UINavigationController(rootViewController: authVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        
        present(navigationController, animated: true)
    }
    
    private func fetchProfileAndSwitch(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                    self?.switchToTabBarController()
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Invalid window configuration")
            return
        }
        
        let tabBarController = MainTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        DispatchQueue.main.async { [weak self] in
            self?.fetchProfileAndSwitch(token: token)
        }
    }
    
    func authViewControllerDidCancel(_ vc: AuthViewController) {
        dismiss(animated: true)
    }
}
