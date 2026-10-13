import SwiftUI

struct ProfileView: View {
    @State private var logoutViewModel: LogoutViewModel
    @State private var showingLogoutConfirmation = false

    init(logoutViewModel: LogoutViewModel) {
        _logoutViewModel = State(initialValue: logoutViewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(AppColors.primary)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Your space")
                            .font(AppFonts.title)
                        Text("A home for everything you shop.")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(AppSpacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text("Your account").font(AppFonts.headline)
                    VStack(spacing: 0) {
                        upcomingRow("My orders", subtitle: "Track your purchases", icon: "shippingbox")
                        Divider().padding(.leading, 60)
                        upcomingRow("Addresses", subtitle: "Manage delivery locations", icon: "mappin.and.ellipse")
                        Divider().padding(.leading, 60)
                        upcomingRow("Settings", subtitle: "Your app preferences", icon: "gearshape")
                    }
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
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
                        } else {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        Text(logoutViewModel.isLoading ? "Logging out…" : "Log out")
                            .font(AppFonts.bodyMedium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(AppColors.error.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
                .foregroundStyle(AppColors.error)
                .disabled(logoutViewModel.isLoading)

                Text("CARTIFY")
                    .font(AppFonts.captionMedium)
                    .tracking(4)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.small)
            }
            .padding(AppSpacing.large)
        }
        .background(AppColors.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Log out of Cartify?", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                Task { await logoutViewModel.logout() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // These sections have no implemented screens yet; don't present inert buttons.
    private func upcomingRow(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColors.primary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title).font(AppFonts.bodyMedium)
                Text(subtitle)
                    .font(AppFonts.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer(minLength: 4)
            Text("Soon")
                .font(AppFonts.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.surface)
                .clipShape(Capsule())
        }
        .padding(AppSpacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). Coming soon.")
    }
}
