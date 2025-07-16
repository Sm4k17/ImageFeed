//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 16.07.2025.
//

import Foundation
import Security

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let service = "com.yourapp.ImageFeed"
    private let account = "OAuth2Token"
    
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
                  let token = String(data: tokenData, encoding: .utf8)
            else {
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
    
    private func baseQuery() -> [String: Any] {
        return [
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
        if status != errSecSuccess {
            print("Error saving token to Keychain: \(status)")
        }
    }
    
    private func delete() {
        let query = baseQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error deleting token from Keychain: \(status)")
        }
    }
}
