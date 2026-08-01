//
//  CouponBanner.swift
//  Cartify
//
//  Created by Soha Elgaly on 26/07/2026.
//
import SwiftUI

struct CouponBanner: View {

    let title: String
    let subtitle: String
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {

            VStack(alignment: .leading, spacing: AppSpacing.xs) {

                Text(title)
                    .font(AppFonts.title)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(AppFonts.body)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Button(action: onButtonTap) {

                Text(buttonTitle)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.vertical, AppSpacing.small)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.large)
        .background(
            LinearGradient(
                colors: [
                    AppColors.primary,
                    AppColors.primary.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large
            )
        )
    }
}

#Preview {
    CouponBanner(
        title: "Summer Sale",
        subtitle: "Up to 50% OFF on selected products",
        buttonTitle: "Shop Now",
        onButtonTap: { }
    )
    .padding()
}
