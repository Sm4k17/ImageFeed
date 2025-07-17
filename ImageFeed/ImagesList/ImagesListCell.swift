//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.06.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Constants
    static let reuseIdentifier = "ImagesListCell"
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        static let likeButtonSize: CGSize = CGSize(width: 42, height: 42)
        static let dateLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)
        static let gradientHeight: CGFloat = 30
    }
    
    // MARK: - UI Elements
    lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.accessibilityIdentifier = "likeButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    private func setupView() {
        backgroundColor = .ypBlack
        selectionStyle = .none
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Cell Image
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: Constants.imageInsets.top),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.imageInsets.left),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -Constants.imageInsets.right),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -Constants.imageInsets.bottom),
            
            // Like Button
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: Constants.likeButtonSize.width),
            likeButton.heightAnchor.constraint(equalToConstant: Constants.likeButtonSize.height),
            
            // Date Label
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor,
                                               constant: Constants.dateLabelInsets.left),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor,
                                              constant: -Constants.dateLabelInsets.bottom)
        ])
    }
    
    // MARK: - Public Methods
    func setLikeButtonImage(isLiked: Bool) {
        let image = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(image, for: .normal)
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
            y: cellImage.bounds.height - Constants.gradientHeight,
            width: cellImage.bounds.width,
            height: Constants.gradientHeight
        )
    }
    
    // MARK: - Actions
    @objc private func didTapLikeButton() {
        // Обработка нажатия на кнопку лайка
    }
}
