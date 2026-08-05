//
//  HomeSearchBar.swift
//  Cartify
//
//  Created by Soha Elgaly on 26/07/2026.
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var searchText: String
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "magnifyingglass")
                .imageScale(.medium)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColors.textSecondary)

            TextField("Search products…", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.body)
                .tint(AppColors.primary)
                .foregroundStyle(AppColors.textPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(AppColors.textSecondary.opacity(0.9), AppColors.cardBackground)
                        .accessibilityLabel("Clear search text")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .frame(height: 52)
        .background(
            AppColors.cardBackground
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    HomeSearchBar(searchText: $searchText)
        .padding()
}
