//
//  LoginViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 28/08/2026.
//

import Foundation
import Observation
@Observable
@MainActor
final class LoginViewModel {
    
    private let repository: AuthRepository
    private let authSession: AuthSession
    var email: String = ""
    var password: String = ""
    var isLoading:Bool = false
    var errorMessage: String?
    
    init(repository: AuthRepository,authSession: AuthSession) {
        self.repository = repository
        self.authSession = authSession
    }
    
    func login() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let authData = try await repository.login(request: LoginRequest(email: email, password: password))
           let user = authData.user
            authSession.authenticate()
            print("Logged in user: \(user)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
