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
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(nil, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.accessibilityIdentifier = "likeButton"
        return button
    }()
    
    // MARK: - Public Properties
        var onLikeButtonTapped: (() -> Void)?
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
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
        likeButton.setImage(nil, for: .normal)
        onLikeButtonTapped = nil
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
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: ImagesListCellConstants.imageInsets.top),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: ImagesListCellConstants.imageInsets.left),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -ImagesListCellConstants.imageInsets.right),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -ImagesListCellConstants.imageInsets.bottom),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.width),
            likeButton.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.height),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor,
                                               constant: ImagesListCellConstants.dateLabelInsets.left),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor,
                                              constant: -ImagesListCellConstants.dateLabelInsets.bottom)
        ])
    }
    
    // MARK: - Public Methods
    func setLikeButtonImage(isLiked: Bool) {
        let imageName = isLiked ? ImagesListCellConstants.Images.likeButtonOn : ImagesListCellConstants.Images.likeButtonOff
        UIView.transition(with: likeButton,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            self.likeButton.setImage(UIImage(named: imageName), for: .normal)
        })
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
    
    func setImage(from url: URL?, placeholder: UIImage?) {
        cellImage.contentMode = .center
        cellImage.image = placeholder
        
        guard let url = url else {
            cellImage.contentMode = .center
            cellImage.image = placeholder
            setupGradient()
            return
        }
        
        cellImage.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.3)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .keepCurrentImageWhileLoading
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            
            // Все UI операции должны быть в главном потоке
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.cellImage.contentMode = .scaleAspectFill
                case .failure:
                    self.cellImage.contentMode = .center
                    self.cellImage.image = placeholder
                }
                self.setupGradient()
            }
        }
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
        onLikeButtonTapped?()
    }
}
