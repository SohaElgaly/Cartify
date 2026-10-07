import SwiftUI

struct ResetPasswordView: View {
    @State private var viewModel: ResetPasswordViewModel
    let onSignInTapped: () -> Void

    init(viewModel: ResetPasswordViewModel, onSignInTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignInTapped = onSignInTapped
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Text("Reset password")
                    .font(AppFonts.title)

                if let message = viewModel.successMessage {
                    Text(message)
                        .foregroundStyle(AppColors.success)
                } else {
                    Text("Copy the full reset code from your email and paste it below. The code expires after 15 minutes.")
                        .foregroundStyle(AppColors.textSecondary)

                    TextField("Reset code from email", text: $viewModel.token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, AppSpacing.medium)
                        .frame(height: 48)
                        .background(AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .stroke(AppColors.border, lineWidth: 1)
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel("Reset code from email")

                    Text("Choose a password with at least 8 characters, including letters and numbers.")
                        .foregroundStyle(AppColors.textSecondary)

                    passwordField("New password", text: $viewModel.password)
                    passwordField("Confirm new password", text: $viewModel.confirmPassword)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                    }

                    Button {
                        Task { await viewModel.resetPassword() }
                    } label: {
                        HStack(spacing: AppSpacing.small) {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text(viewModel.isLoading ? "Resetting…" : "Reset Password")
                        }
                        .font(AppFonts.bodyMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    }
                    .disabled(
                        viewModel.isLoading ||
                        viewModel.token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        viewModel.password.isEmpty ||
                        viewModel.confirmPassword.isEmpty
                    )
                }

                Button("Back to Sign In", action: onSignInTapped)
                    .foregroundStyle(AppColors.primary)
                    .disabled(viewModel.isLoading)
            }
            .font(AppFonts.body)
            .foregroundStyle(AppColors.textPrimary)
            .padding(AppSpacing.large)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading || viewModel.successMessage != nil)
    }

    private func passwordField(_ title: String, text: Binding<String>) -> some View {
        SecureField(title, text: text)
            .textContentType(.newPassword)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, AppSpacing.medium)
            .frame(height: 48)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(AppColors.border, lineWidth: 1)
            }
            .disabled(viewModel.isLoading)
            .accessibilityLabel(title)
    }
}

#if DEBUG
// Previews use a fake repository: pressing Reset never calls the live API.
private final class ResetPasswordPreviewRepository: AuthRepository {
    let expired: Bool

    init(expired: Bool = false) {
        self.expired = expired
    }

    func resetPassword(request: ResetPasswordRequest) async throws -> APIMessageResponse {
        try await Task.sleep(for: .seconds(1))
        if expired {
            throw NetworkError.apiError(
                statusCode: 400, message: "Invalid reset token", code: "INVALID_RESET_TOKEN"
            )
        }
        return APIMessageResponse(success: true, message: "Password reset successfully. Please log in.")
    }

    // These operations are not used by this screen.
    func login(request: LoginRequest) async throws -> AuthData { throw NetworkError.invalidResponse }
    func register(request: RegisterRequest) async throws -> AuthData { throw NetworkError.invalidResponse }
    func refreshToken(refreshToken: String) async throws -> RefreshTokenData { throw NetworkError.invalidResponse }
    func forgotPassword(request: ForgotPasswordRequest) async throws -> APIMessageResponse { throw NetworkError.invalidResponse }
    func logout() async throws { throw NetworkError.invalidResponse }
}

#Preview("Reset password — success") {
    NavigationStack {
        ResetPasswordView(
            viewModel: ResetPasswordViewModel(repository: ResetPasswordPreviewRepository()),
            onSignInTapped: {}
        )
    }
}

#Preview("Reset password — expired code") {
    NavigationStack {
        ResetPasswordView(
            viewModel: ResetPasswordViewModel(repository: ResetPasswordPreviewRepository(expired: true)),
            onSignInTapped: {}
        )
    }
}
#endif
