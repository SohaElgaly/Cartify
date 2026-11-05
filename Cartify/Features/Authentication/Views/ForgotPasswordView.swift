import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel: ForgotPasswordViewModel
    init(viewModel: ForgotPasswordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    var body: some View {
        AuthLayout(title: "Forgot password?", subtitle: "Enter your email and we'll send you a reset code.") {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Email address", text: $viewModel.email)
                    .textContentType(.emailAddress).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .cartifyInput().accessibilityLabel("Email address")
                if let error = viewModel.errorMessage {
                    Text(error).font(AppFonts.caption).foregroundStyle(AppColors.error)
                }
                if let message = viewModel.successMessage {
                    Label(message, systemImage: "envelope.badge")
                        .font(AppFonts.caption).foregroundStyle(AppColors.success)
                }
                PrimaryButton(title: "Send reset code", isLoading: viewModel.isLoading) {
                    Task { await viewModel.forgotPassword() }
                }
                NavigationLink("I already have a code", value: AuthRoute.resetPassword)
                    .font(AppFonts.captionMedium)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .disabled(viewModel.isLoading)
        }
    }
}
