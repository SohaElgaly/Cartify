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
   private(set) var state: AuthState = .restoring
    private let tokenStorage: TokenStorage
    private let profileStorage: UserProfileStorage
    private(set) var currentUser: User?
    
    init(tokenStorage: TokenStorage, profileStorage: UserProfileStorage = UserProfileStorage()) {
        self.tokenStorage = tokenStorage
        self.profileStorage = profileStorage
    }
    
    func restoreSession() {
        guard state == .restoring else { return }
        currentUser = nil
        do {
            let accessToken =  try tokenStorage.getAccessToken()
            let refreshToken = try tokenStorage.getRefreshToken()
            
            if accessToken != nil && refreshToken != nil {
                currentUser = try? profileStorage.load()
                state = .authenticated
            } else {
                try? profileStorage.clear()
                state = .unauthenticated
            }
        } catch {
            state = .unauthenticated
        }
    }
    
    func authenticate(user: User) throws {
        do {
            try profileStorage.save(user)
        } catch {
            try? invalidateSession()
            throw error
        }
        currentUser = user
        state = .authenticated
    }
    func invalidateSession() throws {
        state = .unauthenticated
        currentUser = nil
        let tokenResult = Result { try tokenStorage.clear() }
        let profileResult = Result { try profileStorage.clear() }
        try tokenResult.get()
        try profileResult.get()
    }
}
