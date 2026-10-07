//
//  ForgotPasswordView.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/09/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel: ForgotPasswordViewModel
    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {

        VStack {
            Text("Enter your email to receive a password reset code.")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading,spacing: 20) {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, AppSpacing.medium)
                    .frame(height: 48)
                    .background(
                        AppColors.cardBackground
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                    .tint(AppColors.primary)
                    .foregroundStyle(AppColors.textPrimary)
                    .accessibilityLabel("Email address")

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                }

                if let message = viewModel.successMessage {
                    Text(message)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.success)
                }

                Button {
                    Task {
                        await viewModel.forgotPassword()
                    }
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(viewModel.isLoading ? "Sending…" : "Send")
                            .font(AppFonts.bodyMedium)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColors.primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    )
                }
                .disabled(viewModel.isLoading)

                NavigationLink("I have a reset code", value: AuthRoute.resetPassword)
                    .font(AppFonts.bodyMedium)
                    .foregroundStyle(AppColors.primary)
                    .disabled(viewModel.isLoading)
            }.padding()
        }

    }
}

#Preview {
    ForgotPasswordView(viewModel: AppContainer.shared.makeForgotPasswordViewModel())
}
