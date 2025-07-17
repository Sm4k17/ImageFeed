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
    
    // MARK: - Private Properties
    private let service = KeychainConfig.serviceName
    private let account = KeychainConfig.tokenAccount
    
    // MARK: - Public Properties
    var token: String? {
        get {
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
                return nil
            }
            
            return token
        }
        set {
            if let newValue = newValue {
                add(token: newValue)
            } else {
                delete()
            }
        }
    }
    
    // MARK: - Private Methods
    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
    
    private func add(token: String) {
        delete() // Удаляем старый токен перед добавлением нового
        
        guard let tokenData = token.data(using: .utf8) else { return }
        
        var query = baseQuery()
        query[kSecValueData as String] = tokenData
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Error saving token to Keychain: \(status)")
            return
        }
    }
    
    private func delete() {
        let query = baseQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        guard status != errSecSuccess && status != errSecItemNotFound else { return }
        print("Error deleting token from Keychain: \(status)")
    }
}
