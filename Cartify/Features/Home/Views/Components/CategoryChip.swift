//
//  CategoryChip.swift
//  Cartify
//
//  Created by Soha Elgaly on 26/07/2026.
//

import SwiftUI

struct CategoryChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(isSelected ? AppFonts.title : AppFonts.body)
                .foregroundStyle(
                    isSelected
                    ? Color.white
                    : AppColors.textPrimary
                )
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, AppSpacing.small)
                .background(background)
                .overlay(border)
        }
        .buttonStyle(.plain)
    }
}

private extension CategoryChip {

    var background: some View {
        Capsule()
            .fill(
                isSelected
                ? AppColors.primary
                : AppColors.cardBackground
            )
    }

    var border: some View {
        Capsule()
            .stroke(
                isSelected
                ? .clear
                : AppColors.textSecondary.opacity(0.2),
                lineWidth: 1
            )
    }
}

#Preview {
    HStack(spacing: AppSpacing.small) {
        CategoryChip(
            title: "Electronics",
            isSelected: true,
            action: {}
        )

        CategoryChip(
            title: "Fashion",
            isSelected: false,
            action: {}
        )

        CategoryChip(
            title: "Home",
            isSelected: false,
            action: {}
        )
        CategoryChip(
            title: "Cat Stuff",
            isSelected: false,
            action: {})
    }
    .padding()
}
