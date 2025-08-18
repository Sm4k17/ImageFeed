//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 12.06.2025.
//

import UIKit
import ProgressHUD

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorAnimation = .black
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    
}

