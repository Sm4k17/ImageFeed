//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 09.07.2025.
//

import UIKit
import WebKit

// MARK: - Constants
private enum WebViewConstants {
    static let backButtonSize: CGFloat = 44
    static let backButtonTopInset: CGFloat = 8
    static let backButtonLeadingInset: CGFloat = 8
    static let progressViewTopInset: CGFloat = 8
    
    enum Images {
        static let backButton = "nav_back_button"
    }
}

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    // MARK: - Public Properties
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - UI Components
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.tintColor = .systemBlue
        webView.accessibilityIdentifier = "UnsplashWebView"
        return webView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: WebViewConstants.Images.backButton), for: .normal)
        button.tintColor = .ypBlack
        button.accessibilityIdentifier = "backButton"
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.progressTintColor = .ypBlack
        view.trackTintColor = .ypGray
        view.accessibilityIdentifier = "progressView"
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Setup Methods
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebViewUI()
        setupConstraints()
        setupProgressObserver()
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProgressObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeProgressObserver()
    }
    
    // MARK: - Setup UI
    private func setupWebViewUI() {
        view.backgroundColor = .ypWhite
        [webView, backButton, progressView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: WebViewConstants.backButtonLeadingInset),
            backButton.topAnchor.constraint(equalTo: progressView.bottomAnchor,
                                            constant: WebViewConstants.backButtonTopInset),
            backButton.widthAnchor.constraint(equalToConstant: WebViewConstants.backButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: WebViewConstants.backButtonSize)
        ])
    }
    
    // MARK: - Progress Observation
    private func setupProgressObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] _, change in
            guard let self = self, let newValue = change.newValue else { return }
            self.presenter?.didUpdateProgressValue(newValue)
        }
    }
    
    private func removeProgressObserver() {
        estimatedProgressObservation?.invalidate()
        estimatedProgressObservation = nil
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WebViewViewControllerProtocol
extension WebViewViewController: WebViewViewControllerProtocol {
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.setProgress(newValue, animated: true)
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = AuthHelper.extractCode(from: navigationAction, redirectURI: Constants.redirectURI) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
