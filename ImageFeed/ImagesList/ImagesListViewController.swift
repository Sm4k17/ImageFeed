//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let currentDate = Date() // Единый экземпляр даты для всех ячеек
    private enum Constants {
        // MARK: - Layout Constants
        static let defaultCellHeight: CGFloat = 200
        static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        // MARK: - Like Button Assets
        enum LikeButton {
            static let on = UIImage(named: "like_button_on")
            static let off = UIImage(named: "like_button_off")
        }
        
        // MARK: - Date Formatting
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private var photosName = [String]()
    private var imageSizes = [CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadPhotosAndSizes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupTableView() {
        tableView.contentInset = Constants.tableViewContentInset
    }
    
    private func loadPhotosAndSizes() {
        photosName = (0..<20).compactMap { index in
            let name = "photo_\(index)"
            guard let image = UIImage(named: name) else {
                print("Missing image: \(name)")
                return nil
            }
            imageSizes.append(image.size)
            return name
        }
    }
    
    private func calculateCellHeight(for imageSize: CGSize) -> CGFloat {
        let imageViewWidth = tableView.bounds.width - Constants.imageInsets.left - Constants.imageInsets.right
        let scaleRatio = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scaleRatio
        return imageViewHeight + Constants.imageInsets.top + Constants.imageInsets.bottom
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Загружаем ячейку для indexPath: \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            print("Unable to dequeue ImagesListCell")
            return UITableViewCell()
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        print("Настраиваем ячейку с изображением: \(photoName)")
        cell.cellImage.image = UIImage(named: photoName)
        
        // Форматирование даты
        let dateString = Constants.dateFormatter.string(from: currentDate)
        cell.dateLabel.text = dateString
            .replacingOccurrences(of: " г.", with: "")
            .replacingOccurrences(of: "г.", with: "")
        // Устанавливаем градиент после загрузки изображения
        DispatchQueue.main.async {
            cell.setupGradient()
        }
        let isLiked = indexPath.row % 2 == 0
        cell.likeButton.setImage(isLiked ? Constants.LikeButton.on : Constants.LikeButton.off, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imageSizes.count else {
            return Constants.defaultCellHeight
        }
        return calculateCellHeight(for: imageSizes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
}

