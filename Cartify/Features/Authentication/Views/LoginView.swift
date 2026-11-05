import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    let onRegisterTapped: () -> Void

    init(viewModel: LoginViewModel, onRegisterTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onRegisterTapped = onRegisterTapped
    }

    var body: some View {
        AuthLayout(title: "Welcome back", subtitle: "Sign in to your Cartify account.") {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Email address", text: $viewModel.email)
                    .textContentType(.username).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .cartifyInput().accessibilityLabel("Email address")
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password).cartifyInput()
                    .accessibilityLabel("Password")
                NavigationLink("Forgot password?", value: AuthRoute.forgotPassword)
                    .font(AppFonts.captionMedium)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .trailing)
                if let error = viewModel.errorMessage {
                    Text(error).font(AppFonts.caption).foregroundStyle(AppColors.error)
                }
                PrimaryButton(title: "Sign in", isLoading: viewModel.isLoading,
                              isEnabled: !viewModel.email.isEmpty && !viewModel.password.isEmpty) {
                    Task { await viewModel.login() }
                }
                Button(action: onRegisterTapped) {
                    Text("New to Cartify? Create an account")
                        .font(AppFonts.captionMedium)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}
