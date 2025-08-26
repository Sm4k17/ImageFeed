//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 22.06.2025.
//

import UIKit
import Kingfisher

// MARK: - Constants
private enum SingleImageConstants {
    static let backButtonSize = CGSize(width: 44, height: 44)
    static let backButtonInset: CGFloat = 8
    static let shareButtonSize = CGSize(width: 50, height: 50)
    static let shareButtonBottomInset: CGFloat = 17
    static let minZoomScale: CGFloat = 0.1
    static let maxZoomScale: CGFloat = 1.25
    
    enum Images {
        static let backward = "Backward"
        static let sharing = "Sharing"
    }
}

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    var imageURL: URL? {
        didSet {
            loadImage()
        }
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = SingleImageConstants.minZoomScale
        scrollView.maximumZoomScale = SingleImageConstants.maxZoomScale
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.backward), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.sharing), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        loadImage()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        [scrollView, backButton, shareButton].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Image View
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Back Button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: SingleImageConstants.backButtonInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: SingleImageConstants.backButtonInset),
            backButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.width),
            backButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.height),
            
            // Share Button
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -SingleImageConstants.shareButtonBottomInset),
            shareButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.width),
            shareButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.height)
        ])
    }
    
    // MARK: - Private Methods
    private func loadImage() {
        guard let imageURL = imageURL else {
            showError(message: "Отсутствует URL изображения")
            return
        }
        
        UIBlockingProgressHUD.show() // Показываем индикатор загрузки
        
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss() // Скрываем индикатор после завершения загрузки
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let imageResult):
                    self.imageView.image = imageResult.image
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    if self.imageView.image == nil {
                        self.showError(message: "Не удалось загрузить фото")
                        let pceholderImage = UIImage(systemName: "stab_icon")
                        self.imageView.image = pceholderImage
                        self.imageView.contentMode = .center
                        self.rescaleAndCenterImageInScrollView(image: pceholderImage)
                    }
                }
            }
        }
    }
    
    private func showError(message: String = "Не удалось загрузить фото") {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadImage()
        })
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image else {
            return
        }
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
