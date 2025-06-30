//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 22.06.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            updateImageIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImageIfNeeded()
    }
    
    private func updateImageIfNeeded() {
        guard isViewLoaded else { return }
        imageView.image = image
    }
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
}

