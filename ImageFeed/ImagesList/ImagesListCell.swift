//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.06.2025.
//

import UIKit

// MARK: - Constants
private enum ImagesListCellConstants {
    static let cornerRadius: CGFloat = 16
    static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    static let likeButtonSize: CGSize = CGSize(width: 42, height: 42)
    static let dateLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)
    static let gradientHeight: CGFloat = 30
    static let dateLabelFontSize: CGFloat = 13
    
    enum Images {
        static let likeButtonOn = "like_button_on"
        static let likeButtonOff = "like_button_off"
    }
}

// MARK: - ImagesListCell
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI Elements
    lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ImagesListCellConstants.cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: ImagesListCellConstants.dateLabelFontSize)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.accessibilityIdentifier = "likeButton"
        return button
    }()
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) is not implemented - using programmatic layout")
        return nil
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
    
    // MARK: - Setup Methods
    private func setupCellUI() {
        backgroundColor = .ypBlack
        selectionStyle = .none
        
        [cellImage, likeButton, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Cell Image
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: ImagesListCellConstants.imageInsets.top),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: ImagesListCellConstants.imageInsets.left),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -ImagesListCellConstants.imageInsets.right),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -ImagesListCellConstants.imageInsets.bottom),
            
            // Like Button
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.width),
            likeButton.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.height),
            
            // Date Label
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor,
                                               constant: ImagesListCellConstants.dateLabelInsets.left),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor,
                                              constant: -ImagesListCellConstants.dateLabelInsets.bottom)
        ])
    }
    
    // MARK: - Public Methods
    func setLikeButtonImage(isLiked: Bool) {
        let imageName = isLiked ? ImagesListCellConstants.Images.likeButtonOn : ImagesListCellConstants.Images.likeButtonOff
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func setupGradient() {
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
    
    // MARK: - Private Methods
    private func updateGradientFrame() {
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - ImagesListCellConstants.gradientHeight,
            width: cellImage.bounds.width,
            height: ImagesListCellConstants.gradientHeight
        )
    }
    
    // MARK: - Actions
    @objc private func didTapLikeButton() {
        // Обработка нажатия на кнопку лайка
    }
}
