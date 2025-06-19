//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var photosName = [String]()    // Имена изображений
    private var imageSizes = [CGSize]()    // Размеры изображений
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadPhotosAndSizes()
    }
    
    private func setupTableView() {
        // Регистрация кастомной ячейки из xib
        tableView.register(
            UINib(nibName: "ImagesListCell", bundle: nil),
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )
        
        // Настройка отступов таблицы (12 сверху/снизу)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func loadPhotosAndSizes() {
        // Загрузка 20 изображений и их размеров
        photosName = (0..<20).compactMap { index in
            let name = "photo_\(index)"
            guard let image = UIImage(named: name) else {
                assertionFailure("Missing image: \(name)")
                return nil
            }
            imageSizes.append(image.size)  // Сохраняем размер изображения
            return name
        }
    }
    
    // Расчет высоты ячейки на основе размера изображения
    private func calculateCellHeight(for imageSize: CGSize) -> CGFloat {
        // Отступы вокруг изображения (4pt сверху/снизу, 16pt по бокам)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // Ширина изображения с учетом отступов
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        // Коэффициент масштабирования
        let scaleRatio = imageViewWidth / imageSize.width
        
        // Высота изображения с сохранением пропорций
        let imageViewHeight = imageSize.height * scaleRatio
        
        // Итоговая высота ячейки (изображение + отступы)
        return imageViewHeight + imageInsets.top + imageInsets.bottom
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    // Количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    // Создание и настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Загружаем ячейку для indexPath: \(indexPath.row)")
        // Попытка получить ячейку
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            assertionFailure("Failed to create ImagesListCell")
            return UITableViewCell()  // Возвращаем пустую ячейку в случае ошибки
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
    
    // Настройка содержимого ячейки
    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        print("Настраиваем ячейку с изображением: \(photoName)")
        
        cell.cellImage.image = UIImage(named: photoName) ?? UIImage(systemName: "photo")
        
        // Установка изображения
        cell.cellImage.image = UIImage(named: photoName)
        
        // Установка даты (используется форматтер)
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        // Установка лайка (чётные - on, нечётные - off)
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    // Динамическая высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imageSizes.count else {
            return 200  // Значение по умолчанию если размеры не загружены
        }
        return calculateCellHeight(for: imageSizes[indexPath.row])
    }
}
