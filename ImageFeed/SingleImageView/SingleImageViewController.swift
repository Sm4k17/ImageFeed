//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 22.06.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage? {
        didSet {
            configureImageView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Private functions
    
    private func configureImageView() {
        guard isViewLoaded, let image else { return }
        
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // Центрирование через contentInset
        updateContentInset(for: image.size)
    }
    
    private func updateContentInset(for imageSize: CGSize) {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Вызывается после завершения зума
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        updateContentInset(for: image.size)
    }
    
    // Вызывается после завершения скролла (например, после отпускания пальца)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerImageIfNeeded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerImageIfNeeded()
    }
    
    private func centerImageIfNeeded() {
        guard let image = imageView.image else { return }
        updateContentInset(for: image.size)
    }
}
