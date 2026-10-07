//
//  LogoutViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 29/09/2026.
//

import Foundation
@Observable
@MainActor


class LogoutViewModel {
    
    var isLoading = false
    var errorMessage: String?
    
    private let authRepository: AuthRepository
    private let authSession:AuthSession
    
    init(authRepository: AuthRepository, authSession: AuthSession) {
        self.authRepository = authRepository
        self.authSession = authSession
    }
    
    func logout() async {
        guard !isLoading else { return }
        print("1️⃣ LogoutViewModel.logout started")
        isLoading = true
        errorMessage =  nil
        defer {isLoading = false
            print("5️⃣ LogoutViewModel.logout finished")
        }
        
        do {
            print("2️⃣ Calling authRepository.logout()")
            try await authRepository.logout()
            print("3️⃣ authRepository.logout() succeeded")
            try authSession.invalidateSession()
            print("4️⃣ authSession.invalidateSession() called")
        } catch {
            print("❌ Logout failed:", error)
                    print("❌ Error description:", error.localizedDescription)

            errorMessage = error.localizedDescription
        }
    }
}
