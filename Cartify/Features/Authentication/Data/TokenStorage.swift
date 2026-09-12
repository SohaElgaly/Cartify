//
//  TokenStorage.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/08/2026.
//

import Foundation
import Security

enum TokenStorageError: Error {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
}

final class TokenStorage {
    private let accessTokenKey = "Cartify.accessToken"
    private let refreshTokenKey = "Cartify.refreshToken"
    
    func save(accessToken:String, refreshToken:String) throws {
        let accessData = Data(accessToken.utf8)
        let refreshData = Data(refreshToken.utf8)
        
        try save(data: accessData, key: accessTokenKey)
        try save(data: refreshData, key: refreshTokenKey)
    }
    
    private func save (data: Data,key:String) throws {
        let query:[String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw TokenStorageError.saveFailed(status)
        }
    }
    
    
    
    func getAccessToken() throws -> String? {
        try getToken(for: accessTokenKey)
    }
    func getRefreshToken() throws -> String? {
           try getToken(for: refreshTokenKey)
       }
    
    private func getToken(for key: String) throws -> String? {
        let query:[String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result : AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else
        {
            throw TokenStorageError.readFailed(status)
        }
        guard let data = result as? Data else {
            throw TokenStorageError.readFailed(errSecInternalError)
        }
        return String(data:data,encoding: .utf8)
    }
    
    
    func clear() throws {
        try delete(key: accessTokenKey)
        try delete(key: refreshTokenKey)
    }
    
    private func delete(key: String) throws {
        let query:[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound {
            return
        }
        guard status == errSecSuccess else {
            throw TokenStorageError.deleteFailed(status)
        }
    }
}
