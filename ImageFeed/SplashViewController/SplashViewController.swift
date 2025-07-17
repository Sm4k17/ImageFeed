//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.07.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let storage = OAuth2TokenStorage.shared
    weak var authViewController: AuthViewController?
    
    // MARK: - UI Elements
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LauchScreen")
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
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Auth Flow
    private func checkAuthStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if let token = self.storage.token, !token.isEmpty {
                self.switchToTabBarController()
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
            self?.switchToTabBarController() // Просто переключаемся на таб-бар
        }
    }
    
    func authViewControllerDidCancel(_ vc: AuthViewController) {
        dismiss(animated: true) // Здесь оставляем dismiss, так как это единственное действие
    }
}
