//
//  RatingView.swift
//  Cartify
//
//  Created by Soha Elgaly on 04/08/2026.
//

import SwiftUI


struct RatingView: View {

    let rating: Double
    var reviewCount: Int? = nil

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
                

            Text(ratingFormatted)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)

            if let reviewCount {
                Text("(\(reviewCount))")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var ratingFormatted: String {
        String(format: "%.1f", rating)
    }

    private var accessibilityText: String {
        if let count = reviewCount {
            return "Rating \(ratingFormatted) from \(count) reviews"
        } else {
            return "Rating \(ratingFormatted)"
        }
    }
}

#Preview("Rating only") {
    RatingView(rating: 4.8)
        .padding()
        .background(AppColors.background)
}

#Preview("Rating with reviews") {
    RatingView(rating: 4.8, reviewCount: 512)
        .padding()
        .background(AppColors.background)
}

#Preview("Low rating") {
    RatingView(rating: 1.3, reviewCount: 3)
        .padding()
        .background(AppColors.background)
}
