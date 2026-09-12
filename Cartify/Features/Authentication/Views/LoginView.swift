//
//  LoginView.swift
//  Cartify
//
//  Created by Soha Elgaly on 29/08/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    let onRegisterTapped: () -> Void
    init(viewModel: LoginViewModel,onRegisterTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onRegisterTapped = onRegisterTapped
    }

    var body: some View {
     
            VStack(spacing: AppSpacing.large) {
                Spacer()
                VStack(alignment:.center,spacing: 6) {
                    Text("Welcome back")
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Sign in to continue")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                VStack(spacing: AppSpacing.small) {
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
                    
                    // Password
                    SecureField("Password", text: $viewModel.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
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
                        .accessibilityLabel("Password")
                }
                
                // Error message
                if let error = viewModel.errorMessage, !error.isEmpty {
                    Text(error)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Error: \(error)")
                }
                
                // Sign in button
                Button(action: {
                    Task { await viewModel.login() }
                }) {
                    ZStack {
                        Text(viewModel.isLoading ? "Signing in…" : "Sign In")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(.white)
                            .opacity(viewModel.isLoading ? 0 : 1)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(viewModel.isLoading ? AppColors.primary.opacity(0.6) : AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                }
                .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                
                // Register prompt
                HStack(spacing: 6) {
                    Text("Don’t have an account?")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                    Button {
                        onRegisterTapped()
                    } label: {
                        Text("Register")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(AppColors.primary)
                            .underline()
                            .accessibilityLabel("Register")
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.top, AppSpacing.large)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
}


#Preview {
    LoginView(viewModel: AppContainer.shared.makeLoginViewModel(), onRegisterTapped: {})
}
