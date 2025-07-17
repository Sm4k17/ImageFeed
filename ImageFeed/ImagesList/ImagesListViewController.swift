//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    private let currentDate = Date()
    private var photosName = [String]()
    private var imageSizes = [CGSize]()
    
    // MARK: - Constants
    private enum Constants {
        static let defaultCellHeight: CGFloat = 200
        static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        static let photosCount = 20
        
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
    }
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = Constants.tableViewContentInset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadPhotosAndSizes()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func loadPhotosAndSizes() {
        photosName = (0..<Constants.photosCount).compactMap { index in
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
    
    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        cell.cellImage.image = UIImage(named: photoName)
        
        let dateString = Constants.dateFormatter.string(from: currentDate)
            .replacingOccurrences(of: " г.", with: "")
            .replacingOccurrences(of: "г.", with: "")
        cell.dateLabel.text = dateString
        
        let isLiked = indexPath.row % 2 == 0
        cell.setLikeButtonImage(isLiked: isLiked)
        
        // Устанавливаем градиент после загрузки изображения
        DispatchQueue.main.async {
            cell.setupGradient()
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imageSizes.count else {
            return Constants.defaultCellHeight
        }
        return calculateCellHeight(for: imageSizes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.image = UIImage(named: photosName[indexPath.row])
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
