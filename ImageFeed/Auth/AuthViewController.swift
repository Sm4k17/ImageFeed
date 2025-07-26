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
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchAuthToken(code: code) { [weak self] (result: Result<String, Error>) in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                self.delegate?.authViewController(self, didAuthenticateWithToken: token)
                UIBlockingProgressHUD.succeed()
                
            case .failure(let error):
                self.showAuthError(error)
                UIBlockingProgressHUD.failed()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.dismiss()
    }
    
    // MARK: - Private Methods
    private func showAuthError(_ error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        print("Auth error occurred: \(error)")
    }
}
