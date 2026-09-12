//
//  RegisterView.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/09/2026.
//

import SwiftUI
 
struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    let onSignInTapped: () -> Void
    init(viewModel: RegisterViewModel, onSignInTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignInTapped = onSignInTapped
    }
 
    var body: some View {
            VStack(spacing: AppSpacing.large) {
                Spacer()
                VStack(alignment: .center, spacing: 6) {
                    Text("Create account")
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Sign up to get started")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                VStack(spacing: AppSpacing.small) {
                    // First name & Last name
                    HStack(spacing: AppSpacing.small) {
                        TextField("First name", text: $viewModel.firstName)
                            .textInputAutocapitalization(.words)
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
                            .accessibilityLabel("First name")
                            .onChange(of: viewModel.firstName) { viewModel.firstNameError = nil }
                        
                        TextField("Last name", text: $viewModel.lastName)
                            .textInputAutocapitalization(.words)
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
                            .accessibilityLabel("Last name")
                            .onChange(of: viewModel.lastName) { viewModel.lastNameError = nil }
                    }
                    
                    // First/Last name field errors
                    if let firstNameError = viewModel.firstNameError {
                        Text(firstNameError)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let lastNameError = viewModel.lastNameError {
                        Text(lastNameError)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Email
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
                        .onChange(of: viewModel.email) { viewModel.emailError = nil }
                    
                    if let emailError = viewModel.emailError {
                        Text(emailError)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
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
                        .onChange(of: viewModel.password) { viewModel.passwordError = nil }
                    
                    if let passwordError = viewModel.passwordError {
                        Text(passwordError)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Phone (optional)
                    TextField("Phone (optional)", text: Binding(
                        get: { viewModel.phone ?? "" },
                        set: { viewModel.phone = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.phonePad)
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
                    .accessibilityLabel("Phone number, optional")
                    .onChange(of: viewModel.phone) { viewModel.phoneError = nil }
                    
                    if let phoneError = viewModel.phoneError {
                        Text(phoneError)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Error message
                if let error = viewModel.errorMessage, !error.isEmpty {
                    Text(error)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Error: \(error)")
                }
                
                // Register button
                Button(action: {
                    Task { await viewModel.register() }
                }) {
                    ZStack {
                        Text(viewModel.isLoading ? "Creating account…" : "Create Account")
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
                .disabled(
                    viewModel.isLoading ||
                    viewModel.firstName.isEmpty ||
                    viewModel.lastName.isEmpty ||
                    viewModel.email.isEmpty ||
                    viewModel.password.isEmpty
                )
                .disabled(!viewModel.isFormValid)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                
                // Login prompt
                HStack(spacing: 6) {
                    Text("Already have an account?")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                    Button {
                        onSignInTapped()
                    } label: {
                        Text("Sign In")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(AppColors.primary)
                            .underline()
                            .accessibilityLabel("Sign In")
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
    RegisterView(viewModel: AppContainer.shared.makeRegisterViewModel(), onSignInTapped: {})
}
