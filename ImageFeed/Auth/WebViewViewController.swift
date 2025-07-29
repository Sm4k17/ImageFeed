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
    static let progressComparisonPrecision = 0.0001
    static let progressCornerRadius: CGFloat = 2
    
    enum Images {
        static let backButton = "nav_back_button"
    }
}

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    // MARK: - Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - UI Components
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.tintColor = .systemBlue
        webView.accessibilityIdentifier = "webView"
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
        view.layer.cornerRadius = WebViewConstants.progressCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Setup Methods
    private var estimatedProgressObservation: NSKeyValueObservation? // Наблюдатель за прогрессом
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProgressObserver() // Настраиваем наблюдение при появлении
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeProgressObserver() // Удаляем наблюдение при исчезновении
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebViewUI()
        setupConstraints()
        setupProgressObserver()
        loadAuthView()
        webView.navigationDelegate = self
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
    
    // Очистка данных WebView
    func cleanWebViewData() {
        // Очистка куков
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        // Очистка кеша и данных WKWebView
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records,
                completionHandler: {
                    print("Все данные WKWebView (кеш, куки, localStorage) очищены")
                }
            )
        }
    }
    
    // MARK: - Progress Observation (новое KVO API)
    private func setupProgressObserver() {
        // Создаем наблюдение за свойством estimatedProgress с помощью нового API
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress, // Ключевой путь к свойству
            options: [.new] // Нас интересуют только новые значения
        ) { [weak self] _, _ in
            // При изменении значения обновляем прогресс
            guard let self = self else { return }
            self.updateProgress()
        }
    }
    
    private func removeProgressObserver() {
        // Отменяем наблюдение
        estimatedProgressObservation?.invalidate()
        estimatedProgressObservation = nil
    }
    
    // MARK: - Auth View Loading
    private func loadAuthView() {
        let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        
        guard var urlComponents = URLComponents(string: unsplashAuthorizeURLString) else {
            print("Не удалось создать URL компоненты")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: ImageFeed.Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: ImageFeed.Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: ImageFeed.Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Не удалось создать URL из компонентов")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Code Extraction
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            print("Не удалось получить URL из navigation action")
            return nil
        }
        
        // Проверка стандартного redirect URI
        if url.absoluteString.hasPrefix(ImageFeed.Constants.redirectURI),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            print("Извлечен код из redirect URI: \(codeItem.value ?? "")")
            return codeItem.value
        }
        
        // Проверка native URL
        if url.absoluteString.contains("unsplash.com/oauth/authorize/native"),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            print("Извлечен код из native URL: \(codeItem.value ?? "")")
            return codeItem.value
        }
        
        // Общая проверка параметра code
        if url.absoluteString.contains("code="),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            print("Извлечен код из generic URL: \(codeItem.value ?? "")")
            return codeItem.value
        }
        
        print("Код не найден в URL: \(url.absoluteString)")
        return nil
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Progress Updates
    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)
        progressView.setProgress(progress, animated: true)
        progressView.isHidden = isProgressComplete(webView.estimatedProgress)
    }
    
    private func isProgressComplete(_ progress: Double) -> Bool {
        return fabs(progress - 1.0) <= WebViewConstants.progressComparisonPrecision
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else {
                decisionHandler(.allow)
                return
            }
            
            if let code = self.code(from: navigationAction) {
                DispatchQueue.main.async {
                    self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
