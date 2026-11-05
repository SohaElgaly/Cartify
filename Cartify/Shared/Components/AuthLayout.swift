import SwiftUI

struct AuthLayout<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 60, height: 60)
                    .background(AppColors.primary.opacity(0.09), in: RoundedRectangle(cornerRadius: 20))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title).font(AppFonts.largeTitle)
                    Text(subtitle).font(AppFonts.body).foregroundStyle(AppColors.textSecondary)
                }
                content
            }
            .padding(24)
            .frame(maxWidth: 520, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .foregroundStyle(AppColors.textPrimary)
        .tint(AppColors.primary)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func cartifyInput() -> some View {
        self
            .font(AppFonts.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 54)
            .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.border, lineWidth: 0.7))
    }
}
