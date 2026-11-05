import SwiftUI

struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    let onSignInTapped: () -> Void

    init(viewModel: RegisterViewModel, onSignInTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignInTapped = onSignInTapped
    }

    var body: some View {
        AuthLayout(title: "Make it yours", subtitle: "Create an account to start shopping.") {
            VStack(alignment: .leading, spacing: 16) {
                TextField("First name", text: $viewModel.firstName)
                    .textContentType(.givenName).textInputAutocapitalization(.words)
                    .cartifyInput().accessibilityLabel("First name")
                    .onChange(of: viewModel.firstName) { viewModel.firstNameError = nil }
                fieldError(viewModel.firstNameError)
                TextField("Last name", text: $viewModel.lastName)
                    .textContentType(.familyName).textInputAutocapitalization(.words)
                    .cartifyInput().accessibilityLabel("Last name")
                    .onChange(of: viewModel.lastName) { viewModel.lastNameError = nil }
                fieldError(viewModel.lastNameError)
                TextField("Email address", text: $viewModel.email)
                    .textContentType(.emailAddress).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .cartifyInput().accessibilityLabel("Email address")
                    .onChange(of: viewModel.email) { viewModel.emailError = nil }
                fieldError(viewModel.emailError)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword).cartifyInput()
                    .accessibilityLabel("Password")
                    .onChange(of: viewModel.password) { viewModel.passwordError = nil }
                Text("At least 8 characters, including letters and numbers.")
                    .font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
                fieldError(viewModel.passwordError)
                TextField("Phone number (optional)", text: Binding(
                    get: { viewModel.phone ?? "" },
                    set: { viewModel.phone = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.telephoneNumber).keyboardType(.phonePad)
                .cartifyInput().accessibilityLabel("Phone number, optional")
                .onChange(of: viewModel.phone) { viewModel.phoneError = nil }
                fieldError(viewModel.phoneError)
                fieldError(viewModel.errorMessage)
                PrimaryButton(title: "Create account", isLoading: viewModel.isLoading, isEnabled: viewModel.isFormValid) {
                    Task { await viewModel.register() }
                }
                Button("Already have an account? Sign in", action: onSignInTapped)
                    .font(AppFonts.captionMedium)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .disabled(viewModel.isLoading)
        }
    }

    @ViewBuilder private func fieldError(_ message: String?) -> some View {
        if let message {
            Text(message).font(AppFonts.caption).foregroundStyle(AppColors.error)
        }
    }
}
