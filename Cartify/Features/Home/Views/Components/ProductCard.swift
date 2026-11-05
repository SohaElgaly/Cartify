//
//  ProductCard.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct ProductCard: View {

    let product: Product
    var showsPrice = true

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

    }
}

// MARK: - SubViews

private extension ProductCard {

    var imageSection: some View {
        Color.white
            .frame(height: 170)
            .overlay {
                NetworkImage(
                    url: product.images?.first.flatMap(URL.init(string:)),
                    contentMode: .fit
                )
                .padding(12)
            }
            .clipped()
            .accessibilityHidden(true)
    }

    var informationSection: some View {
        VStack(alignment: .leading,
               spacing: AppSpacing.xs) {

            Text(product.title)
                .font(AppFonts.bodyMedium)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(AppColors.textPrimary)
                

            if let brand = product.brand, !brand.isEmpty {
                Text(brand)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if product.rating > 0 {
                RatingView(rating: product.rating)
            }

            if showsPrice {
                PriceView(price: product.price, discountedPrice: product.discountPrice)
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.bottom, showsPrice ? AppSpacing.medium : AppSpacing.xs)
    }
}

#Preview {
    ProductCard(product: .mock)
        .frame(width: 180)
        .padding()
        .background(AppColors.background)
}
