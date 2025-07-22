//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 16.07.2025.
//

import Foundation
import Security

final class OAuth2TokenStorage {
    
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {
        debugPrint("OAuth2TokenStorage инициализирован")
    }
    
    // MARK: - Keychain Configuration
    private enum KeychainConfig {
        static let serviceName = "ru.yandex.practicum.ImageF8eed"
        static let tokenAccount = "OAuth2Token"
        static let accessible = kSecAttrAccessibleAfterFirstUnlock
    }
    
    // MARK: - Public Properties
    var token: String? {
        get { retrieveToken() }
        set { updateToken(newValue) }
    }
    
    // MARK: - Keychain Operations
    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConfig.serviceName,
            kSecAttrAccount as String: KeychainConfig.tokenAccount
        ]
    }
    
    private func retrieveToken() -> String? {
        var query = baseQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            debugPrint("Токен не найден в Keychain. Статус: \(status.message)")
            return nil
        }
        
        debugPrint("Токен успешно получен из Keychain")
        return token
    }
    
    private func updateToken(_ newToken: String?) {
        if let token = newToken {
            saveToken(token)
        } else {
            removeToken()
        }
    }
    
    private func saveToken(_ token: String) {
        removeToken() // Удаляем предыдущий токен
        
        guard let tokenData = token.data(using: .utf8) else {
            debugPrint("Ошибка преобразования токена в Data")
            return
        }
        
        var query = baseQuery()
        query[kSecValueData as String] = tokenData
        query[kSecAttrAccessible as String] = KeychainConfig.accessible
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            debugPrint("Токен успешно сохранен в Keychain")
        } else {
            debugPrint("Ошибка сохранения токена в Keychain: \(status.message)")
        }
    }
    
    private func removeToken() {
        let query = baseQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess:
            debugPrint("Токен успешно удален из Keychain")
        case errSecItemNotFound:
            debugPrint("Токен не найден для удаления")
        default:
            debugPrint("Ошибка удаления токена: \(status.message)")
        }
    }
    
    // MARK: - Debug
    func logKeychainStatus() {
        let status = token != nil ? "Токен существует" : "Токен отсутствует"
        debugPrint("Статус Keychain: \(status)")
    }
}

// MARK: - Keychain Error Handling
extension OSStatus {
    var message: String {
        if let message = SecCopyErrorMessageString(self, nil) as String? {
            return message
        }
        return "Неизвестная ошибка Keychain (\(self))"
    }
}
