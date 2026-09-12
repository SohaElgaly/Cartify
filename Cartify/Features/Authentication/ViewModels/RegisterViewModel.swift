//
//  RegisterViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/09/2026.
//

import Foundation
@Observable
@MainActor
 
final class RegisterViewModel {
    
    private let repository: AuthRepository
    private let authSession: AuthSession
    
    var firstName:String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var phone: String?
    var isLoading:Bool = false
    var errorMessage: String?
 
    // MARK: - Field-level validation errors
    var firstNameError: String?
    var lastNameError: String?
    var emailError: String?
    var passwordError: String?
    var phoneError: String?
 
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        firstNameError == nil &&
        lastNameError == nil &&
        emailError == nil &&
        passwordError == nil &&
        phoneError == nil
    }
    
    init(repository: AuthRepository, authSession: AuthSession) {
        self.repository = repository
        self.authSession = authSession
       
    }
 
    // MARK: - Validation
 
    @discardableResult
    func validate() -> Bool {
        firstNameError = validateFirstName()
        lastNameError = validateLastName()
        emailError = validateEmail()
        passwordError = validatePassword()
        phoneError = validatePhone()
 
        return firstNameError == nil &&
            lastNameError == nil &&
            emailError == nil &&
            passwordError == nil &&
            phoneError == nil
    }
 
    private func validateFirstName() -> String? {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "First name is required."
        }
        if trimmed.count < 2 {
            return "First name must be at least 2 characters."
        }
        return nil
    }
 
    private func validateLastName() -> String? {
        let trimmed = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Last name is required."
        }
        if trimmed.count < 2 {
            return "Last name must be at least 2 characters."
        }
        return nil
    }
 
    private func validateEmail() -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Email is required."
        }
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if trimmed.range(of: emailRegex, options: .regularExpression) == nil {
            return "Enter a valid email address."
        }
        return nil
    }
 
    private func validatePassword() -> String? {
        if password.isEmpty {
            return "Password is required."
        }
        if password.count < 8 {
            return "Password must be at least 8 characters."
        }
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        if !hasLetter || !hasDigit {
            return "Password must contain letters and numbers."
        }
        return nil
    }
 
    private func validatePhone() -> String? {
        guard let phone, !phone.isEmpty else { return nil }
        let phoneRegex = #"^[0-9+\-\s]{7,15}$"#
        if phone.range(of: phoneRegex, options: .regularExpression) == nil {
            return "Enter a valid phone number."
        }
        return nil
    }
    
    func register() async {
        errorMessage = nil
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let authData = try await repository.register(request: RegisterRequest(firstName:firstName,lastName:lastName,email: email, password: password, phone: phone))
           let user = authData.user
            authSession.authenticate()
            print("user registered: \(user)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
 
