//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 09.07.2025.
//

import UIKit

// MARK: - Constants
private enum AuthConstants {
    static let logoSize: CGFloat = 60
    static let buttonHeight: CGFloat = 48
    static let buttonBottomInset: CGFloat = 90
    static let horizontalInset: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 16
    static let buttonFontSize: CGFloat = 17
    
    enum Images {
        static let authLogo = "auth_screen_logo"
    }
    
    enum Texts {
        static let loginButton = "Войти"
    }
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController {
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - UI Components
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: AuthConstants.Images.authLogo))
        imageView.accessibilityIdentifier = "authLogo"
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = AuthConstants.buttonCornerRadius
        button.setTitle(AuthConstants.Texts.loginButton, for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: AuthConstants.buttonFontSize, weight: .bold)
        button.accessibilityIdentifier = "loginButton"
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAuthUI()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupAuthUI() {
        [logoView, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoView.heightAnchor.constraint(equalToConstant: AuthConstants.logoSize),
            logoView.widthAnchor.constraint(equalToConstant: AuthConstants.logoSize),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.heightAnchor.constraint(equalToConstant: AuthConstants.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: AuthConstants.horizontalInset),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -AuthConstants.horizontalInset),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                constant: -AuthConstants.buttonBottomInset),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapLoginButton() {
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self
        webViewVC.modalPresentationStyle = .fullScreen
        present(webViewVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        startAuthProcess()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            OAuth2Service.shared.fetchAuthToken(code: code) { result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let token):
                        self.handleAuthSuccess(token: token)
                    case .failure(let error):
                        self.handleAuthFailure(error: error)
                    }
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        handleAuthCancellation()
    }
    
    // MARK: - Private Methods
    private func startAuthProcess() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = false
            self.loginButton.alpha = 0.5
        }
    }
    
    private func endAuthProcess() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = true
            self.loginButton.alpha = 1.0
        }
    }
    
    private func handleAuthSuccess(token: String) {
        DispatchQueue.global(qos: .utility).async {
            OAuth2TokenStorage.shared.token = token
        }
        
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.authViewController(self, didAuthenticateWithToken: token)
            self.dismiss(animated: true)
        }
    }
    
    private func handleAuthFailure(error: Error) {
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            self?.showAuthError(error)
            self?.dismiss(animated: true)
        }
    }
    
    private func handleAuthCancellation() {
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func showAuthError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
