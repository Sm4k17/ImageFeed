//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.06.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    private let gradientHeight: CGFloat = 30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        dateLabel.text = nil
    }
    
    func setupGradient() {
        // Удаляем старый градиент если есть
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradient.locations = [0, 1]
        gradientLayer = gradient
        updateGradientFrame()
        cellImage.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupViews() {
        guard cellImage.bounds.height > 0 else { return }
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - gradientHeight,
            width: cellImage.bounds.width,
            height: gradientHeight
        )
    }
    
    private func updateGradientFrame() {
        // Убедимся, что градиент всегда внизу изображения
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - gradientHeight,
            width: cellImage.bounds.width,
            height: gradientHeight
        )
    }
}
