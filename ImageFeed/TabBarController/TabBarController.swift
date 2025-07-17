//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.07.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTabBar()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        tabBar.barTintColor = .ypBlack
        tabBar.tintColor = .ypWhite
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.isTranslucent = false // Убираем прозрачность
    }
    
    private func setupTabBar() {
        guard let editorialImage = UIImage(named: "tab_editorial_active"),
              let profileImage = UIImage(named: "tab_profile_active") else {
            print("Missing tab bar images. Проверьте Assets.")
            return
        }
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        // Настройка таб-бара
        imagesListVC.tabBarItem = UITabBarItem(title: nil, image: editorialImage, tag: 0)
        profileVC.tabBarItem = UITabBarItem(title: nil, image: profileImage, tag: 1)
        
        viewControllers = [imagesListVC, profileVC]
    }
}
