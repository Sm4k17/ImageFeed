//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.06.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // Статический идентификатор для переиспользования ячейки
    static let reuseIdentifier = "ImagesListCell"
    
    // Аутлеты из xib-файла
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Очистка изображения при переиспользовании ячейки
        cellImage.image = nil
    }
}
