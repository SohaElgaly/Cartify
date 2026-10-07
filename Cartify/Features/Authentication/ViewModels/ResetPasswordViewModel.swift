import Foundation
import Observation

@Observable
@MainActor
final class ResetPasswordViewModel {
    var token = ""
    var password = ""
    var confirmPassword = ""
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func resetPassword() async {
        guard !isLoading, successMessage == nil else { return }
        errorMessage = nil

        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            errorMessage = "Enter the reset code from your email."
            return
        }
        // Match the password rules used during registration. Never trim passwords.
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }
        guard password.rangeOfCharacter(from: .letters) != nil,
              password.rangeOfCharacter(from: .decimalDigits) != nil else {
            errorMessage = "Password must contain letters and numbers."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await repository.resetPassword(
                request: ResetPasswordRequest(token: trimmedToken, password: password)
            )
            guard response.success else {
                errorMessage = response.message
                return
            }
            token = ""
            password = ""
            confirmPassword = ""
            successMessage = response.message
        } catch NetworkError.apiError(_, _, let code) where code == "INVALID_RESET_TOKEN" {
            errorMessage = "This reset code is invalid or has expired. Request a new reset email."
        } catch NetworkError.transport(let underlyingError) {
            if let urlError = underlyingError as? URLError, urlError.code == .timedOut {
                errorMessage = "The request timed out. Your password may have changed. Try signing in with the new password before requesting another reset email."
            } else {
                errorMessage = "Unable to complete the request. Check your connection and try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
