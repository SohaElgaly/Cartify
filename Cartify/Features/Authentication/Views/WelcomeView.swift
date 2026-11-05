import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(AppColors.primaryLight, in: RoundedRectangle(cornerRadius: 32))
                Text("Good finds.\nAll in one place.")
                    .font(AppFonts.largeTitle)
                Text("Discover your favorites, build your bag and follow every order.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                Label("Discover something new", systemImage: "sparkles")
                Label("Keep your favorites in your cart", systemImage: "bag")
                Label("Follow your order's progress", systemImage: "shippingbox")
                PrimaryButton(title: "Let's explore", action: onContinue)
            }
            .padding(28)
            .frame(maxWidth: 520, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(AppColors.textPrimary)
        .background(AppColors.background)
    }
}
