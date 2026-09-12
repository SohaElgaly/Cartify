//
//  AuthSession.swift
//  Cartify
//
//  Created by Soha Elgaly on 28/08/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class AuthSession {
   private(set) var state: AuthState = .unauthenticated
    private let tokenStorage: TokenStorage
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    func restoreSession() {
        do {
            let accessToken =  try tokenStorage.getAccessToken()
            let refreshToken = try tokenStorage.getRefreshToken()
            
            if accessToken != nil && refreshToken != nil {
                state = .authenticated
            } else {
                state = .unauthenticated
            }
        } catch {
            state = .unauthenticated
        }
    }
    
    func authenticate() {
        state = .authenticated
    }
    func logout() throws {
        try tokenStorage.clear()
        state = .unauthenticated
    }
}
