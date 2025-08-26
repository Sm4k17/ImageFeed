//
//  GradientView.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 19.08.2025.
//

import UIKit

final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    // Настройки градиента по умолчанию для shimmer-эффекта
    static var shimmerColors: [UIColor] = [
        UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1),
        UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1),
        UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1)
    ]
    
    static var shimmerStartPoint: CGPoint = CGPoint(x: 0, y: 0.5)
    static var shimmerEndPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    
    // Публичные свойства
    var colors: [UIColor] = [.ypBlack.withAlphaComponent(0), .ypBlack.withAlphaComponent(0.2)] {
        didSet { updateGradient() }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { gradientLayer.startPoint = startPoint }
    }
    
    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { gradientLayer.endPoint = endPoint }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            gradientLayer.cornerRadius = cornerRadius
            layer.cornerRadius = cornerRadius
        }
    }
    
    var isShimmering: Bool = false {
        didSet {
            if isShimmering {
                setupShimmer()
            } else {
                stopShimmer()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    // MARK: - Shimmer Effect
    private func setupShimmer() {
        // Устанавливаем настройки для shimmer-эффекта
        gradientLayer.colors = GradientView.shimmerColors.map { $0.cgColor }
        gradientLayer.startPoint = GradientView.shimmerStartPoint
        gradientLayer.endPoint = GradientView.shimmerEndPoint
        
        // Настраиваем анимацию
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    private func stopShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmerAnimation")
        // Возвращаем стандартные настройки
        updateGradient()
    }
    
    // MARK: - Convenience Methods
    static func createShimmerView(frame: CGRect, cornerRadius: CGFloat = 0) -> GradientView {
        let view = GradientView(frame: frame)
        view.isShimmering = true
        view.cornerRadius = cornerRadius
        view.clipsToBounds = true
        return view
    }
}
