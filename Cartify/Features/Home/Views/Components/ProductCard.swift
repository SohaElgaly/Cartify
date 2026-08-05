//
//  ProductCard.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct ProductCard: View {

    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {

            imageSection

            informationSection
        }
        .background(AppColors.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.medium
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.medium
            )
            .stroke(AppColors.border, lineWidth: 1)
        }
    }
}

// MARK: - SubViews

private extension ProductCard {

    var imageSection: some View {
        NetworkImage(
            url: nil,
        )
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.medium
            )
        )
    }

    var informationSection: some View {
        VStack(alignment: .leading,
               spacing: AppSpacing.xs) {

            Text(product.title)
                .font(AppFonts.headline)
                .lineLimit(2)
                .foregroundStyle(AppColors.textPrimary)
                

            Text(product.brand)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)

            RatingView(rating: product.rating)

            PriceView(price: product.price)
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.bottom, AppSpacing.medium)
    }
}

#Preview {
    ProductCard(product: .mock)
        .frame(width: 180)
        .padding()
        .background(AppColors.background)
}
