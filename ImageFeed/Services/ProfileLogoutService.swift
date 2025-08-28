//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 18.08.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanAuthData()
        resetServicesData()
        switchToSplashScreen()
    }
    
    private func cleanAuthData() {
        // Удаляем OAuth токен
        OAuth2TokenStorage.shared.token = nil
        
        // Очищаем данные WebView
        cleanWebViewData()
    }
    
    private func cleanWebViewData() {
        // Очищаем HTTP куки
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        // Очищаем WKWebView данные (кеш, куки, localStorage)
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date.distantPast
        ) {
            print("Все данные WebView очищены")
        }
    }
    
    private func resetServicesData() {
        // Сбрасываем аватар
        ProfileImageService.shared.clearAvatarURL()
        
        // Очищаем список фотографий
        ImagesListService.shared.resetPhotos()
    }
    
    private func switchToSplashScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
            
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
}
