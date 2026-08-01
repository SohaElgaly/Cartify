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
                .foregroundStyle(AppColors.textSecondary)
            TextField("Search products...", text: $searchText)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                     .foregroundStyle(AppColors.textSecondary)
                }
            }
        }.padding(.horizontal, AppSpacing.medium)
            .frame(height: 52)
            .background(AppColors.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.medium
                )
            )
    }
}

#Preview {
    @Previewable @State var searchText = ""
    HomeSearchBar(searchText: $searchText)
        .padding()
}
