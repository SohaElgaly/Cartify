//
//  PriceView.swift
//  Cartify
//
//  Created by Soha Elgaly on 04/08/2026.
//

import SwiftUI

/// PriceView
/// Displays product pricing with optional discount handling.
///
/// - Minimal API: current price, optional discounted price, configurable currency symbol
/// - Uses AppFonts, AppColors, AppSpacing
/// - No hardcoded frames; parent controls layout
struct PriceView: View {

    let price: Double
    var discountedPrice: Double? = nil
    var currencySymbol: String = "$"

    private var hasValidDiscount: Bool {
        if let discountedPrice, discountedPrice < price { return true }
        return false
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%@%.2f", currencySymbol, value)
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // Primary (current selling) price
            Text(formatted(hasValidDiscount ? (discountedPrice ?? price) : price))
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.primary)

            // Original price (only when a valid discount exists)
            if hasValidDiscount {
                Text(formatted(price))
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .strikethrough(true, color: AppColors.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if hasValidDiscount, let discountedPrice {
            return "Discounted price \(formatted(discountedPrice)). Original price \(formatted(price))."
        } else {
            return "Price \(formatted(price))."
        }
    }
}

#Preview("Regular price only") {
    PriceView(price: 249)
        .padding()
        .background(AppColors.background)
}
#Preview("Discounted product") {
    PriceView(price: 249, discountedPrice: 219)
        .padding()
        .background(AppColors.background)
}

#Preview("Invalid discount (equal)") {
    PriceView(price: 249, discountedPrice: 249)
        .padding()
        .background(AppColors.background)
}

#Preview("Invalid discount (higher)") {
    PriceView(price: 249, discountedPrice: 299)
        .padding()
        .background(AppColors.background)
}

