//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit

// MARK: - Constants
private enum ImagesListConstants {
    static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    
    // MARK: - Alert Texts
    static let likeErrorAlertTitle = "Ошибка"
    static let likeErrorMessage = "Не удалось изменить лайк"
    static let okButtonTitle = "OK"
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    private let presenter: ImagesListPresenterProtocol
    private let refreshControl = UIRefreshControl()
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = ImagesListConstants.tableViewContentInset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initialization
    init(presenter: ImagesListPresenterProtocol = ImagesListPresenter()) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRefreshControl()
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .ypWhite
        refreshControl.addTarget(self, action: #selector(refreshPhotos(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Action Methods
    @objc private func refreshPhotos(_ sender: Any) {
        presenter.refreshPhotos()
    }
    
    @objc private func didTapLikeButton(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ImagesListCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        presenter.didTapLikeButton(at: indexPath.row, cell: cell)
    }
    
    private func showLikeErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: ImagesListConstants.likeErrorAlertTitle,
            message: "\(ImagesListConstants.likeErrorMessage): \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: ImagesListConstants.okButtonTitle,
            style: .default
        ))
        present(alert, animated: true)
    }
}

// MARK: - ImagesListViewProtocol
extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
        refreshControl.endRefreshing()
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLikeError(error: Error) {
        showLikeErrorAlert(error: error)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        presenter.configureCell(cell, at: indexPath)
        cell.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.calculateCellHeight(for: indexPath, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photosCount - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectPhoto(at: indexPath.row)
    }
}
