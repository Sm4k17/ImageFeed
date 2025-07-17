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
                  let retrievedToken = String(data: tokenData, encoding: .utf8) else {
                print("No token found in Keychain")
                return nil
            }
            
            print("Retrieved token from Keychain: \(retrievedToken)")
            return retrievedToken
        }
        set {
            if let tokenToStore = newValue {
                print("Storing new token in Keychain")
                add(token: tokenToStore)
            } else {
                print("Removing token from Keychain")
                delete()
            }
        }
    }
    
    // MARK: - Keychain Operations
    
    // MARK: Base Query
    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
    
    // MARK: Add Token
    private func add(token: String) {
        delete() // Удаляем старый токен перед добавлением нового
        
        guard let tokenData = token.data(using: .utf8) else {
            print("Failed to convert token to Data")
            return
        }
        
        var query = baseQuery()
        query[kSecValueData as String] = tokenData
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving token to Keychain: \(status)")
        }
    }
    
    // MARK: Delete Token
    private func delete() {
        let query = baseQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("Token successfully deleted from Keychain")
        } else if status == errSecItemNotFound {
            print("No token found to delete")
        } else {
            print("Error deleting token from Keychain: \(status)")
        }
    }
    
    // MARK: - Debug Helpers
    func printKeychainStatus() {
        let status = token == nil ? "No token" : "Token exists"
        print("Keychain status: \(status)")
    }
}
