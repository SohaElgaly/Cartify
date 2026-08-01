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
            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        }
    }
}

// MARK: - Components

private extension ProductCard {

    var imageSection: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .overlay {

                Image(systemName: "photo")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)

                // Later:
                //
                // AsyncImage(url: URL(string: product.thumbnail))
                //
            }
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
                .frame(height: 20, alignment: .topLeading)
                .foregroundStyle(AppColors.textPrimary)
                

            Text(product.brand)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.xs) {

                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)

                Text(product.rating.formatted())
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(product.price,
                 format: .currency(code: "GBP"))
            .font(AppFonts.headline)
            .foregroundStyle(AppColors.primary)
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.bottom, AppSpacing.medium)
    }
}

#Preview {
    ProductCard(product: .mock)
    .frame(width: 200)
    .padding()
}
