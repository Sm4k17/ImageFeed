//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 17.07.2025.
//

import UIKit

// MARK: - Constants
private enum TabBarConstants {
    enum Images {
        static let editorialActive = "tab_editorial_active"
        static let profileActive = "tab_profile_active"
    }
    
    enum TabBar {
        static let tintColor: UIColor = .ypWhite
        static let unselectedTintColor: UIColor = .ypGray
        static let backgroundColor: UIColor = .ypBlack
        static let isTranslucent: Bool = false
    }
}

final class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTabBar()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = TabBarConstants.TabBar.backgroundColor
        tabBar.barTintColor = TabBarConstants.TabBar.backgroundColor
        tabBar.tintColor = TabBarConstants.TabBar.tintColor
        tabBar.unselectedItemTintColor = TabBarConstants.TabBar.unselectedTintColor
        tabBar.isTranslucent = TabBarConstants.TabBar.isTranslucent
    }
    
    private func setupTabBar() {
        guard let editorialImage = UIImage(named: TabBarConstants.Images.editorialActive),
              let profileImage = UIImage(named: TabBarConstants.Images.profileActive) else {
            print("Missing tab bar images. Проверьте Assets.")
            return
        }
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: editorialImage,
            tag: 0
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: profileImage,
            tag: 1
        )
        
        viewControllers = [imagesListVC, profileVC]
    }
}
