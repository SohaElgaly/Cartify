import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var logoutViewModel: LogoutViewModel
    @State private var showingLogoutConfirmation = false
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeProfileViewModel())
        _logoutViewModel = State(initialValue: container.makeLogoutViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                identityCard

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text("Your account").font(AppFonts.headline)
                    VStack(spacing: 0) {
                        NavigationLink {
                            OrdersView(viewModel: container.makeOrdersViewModel())
                        } label: {
                            row("My orders", subtitle: "View purchases and order status", icon: "shippingbox")
                        }
                        Divider().padding(.leading, 60)
                        NavigationLink {
                            AddressesView(
                                viewModel: container.makeAddressesViewModel(),
                                makeFormViewModel: { container.makeAddressFormViewModel(address: $0) }
                            )
                        } label: {
                            row("Addresses", subtitle: "Add and manage delivery addresses", icon: "mappin.and.ellipse")
                        }
                        Divider().padding(.leading, 60)
                        NavigationLink {
                            ProfileSettingsView()
                        } label: {
                            row("Settings", subtitle: "Appearance and app information", icon: "gearshape")
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(logoutViewModel.isLoading)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }

                if let message = logoutViewModel.errorMessage {
                    Text(message)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                }

                Button(role: .destructive) {
                    showingLogoutConfirmation = true
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        if logoutViewModel.isLoading {
                            ProgressView().tint(AppColors.error)
                            Text("Logging out…")
                        } else {
                            Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    .font(AppFonts.bodyMedium)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(AppColors.error.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
                .foregroundStyle(AppColors.error)
                .disabled(logoutViewModel.isLoading)


            }
            .padding(AppSpacing.large)
        }
        .background(AppColors.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Log out of Cartify?", isPresented: $showingLogoutConfirmation) {
            Button("Log out", role: .destructive) {
                Task { await logoutViewModel.logout() }
            }
            Button("Stay signed in", role: .cancel) {}
        } message: {
            Text("You'll need to sign in again to access your cart and orders.")
        }
    }

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.medium) {
                ZStack {
                    Circle().fill(AppColors.primary.opacity(0.12))
                    if viewModel.initials.isEmpty {
                        Image(systemName: "person.crop.circle").font(.largeTitle)
                    } else {
                        Text(viewModel.initials).font(AppFonts.title).minimumScaleFactor(0.5)
                            .padding(8)
                    }
                }
                .foregroundStyle(AppColors.primary)
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    if let user = viewModel.user {
                        Text(viewModel.fullName).font(AppFonts.title)
                        Text(user.email)
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .textSelection(.enabled)
                    } else {
                        Text("Your account").font(AppFonts.title)
                    }
                }
            }
            if viewModel.user == nil {
                Text("Sign out and sign in again to load your name and email for this account.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.large)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
    }

    private func row(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColors.primary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title).font(AppFonts.bodyMedium)
                Text(subtitle).font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).accessibilityHidden(true)
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(AppSpacing.medium)
        .frame(minHeight: 60)
    }
}
