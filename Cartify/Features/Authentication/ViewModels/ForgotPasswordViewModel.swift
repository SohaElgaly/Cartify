//
//  ForgotPasswordViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/09/2026.
//

import Foundation
@Observable
@MainActor

class ForgotPasswordViewModel {
    var email: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var successMessage: String?
    
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func forgotPassword() async {
        guard !isLoading else { return }

        errorMessage = nil
        successMessage = nil

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if let validationError = validateEmail(trimmedEmail) {
            errorMessage = validationError
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authRepository.forgotPassword(
                request: ForgotPasswordRequest(email: trimmedEmail)
            )

            if response.success {
                successMessage = response.message
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validateEmail(_ email: String) -> String? {
        if email.isEmpty {
            return "Email is required."
        }

        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        if email.range(of: emailRegex, options: .regularExpression) == nil {
            return "Enter a valid email address."
        }

        return nil
    }
}
