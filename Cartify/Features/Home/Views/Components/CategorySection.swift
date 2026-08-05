//
//  CategorySection.swift
//  Cartify
//
//  Created by Soha Elgaly on 26/07/2026.
//

import SwiftUI

struct CategorySection: View {

    let title: String
    let categories: [Category]
    let selectedCategory: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {

            Text(title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                //.padding(.horizontal, AppSpacing.medium)

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: AppSpacing.small) {

                    ForEach(categories) { category in

                        CategoryChip(
                            title: category.name,
                            isSelected: category.id == selectedCategory,
                            action: {
                                onSelect(category.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.medium)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory = "Electronics"

    CategorySection(
        title: "Categories",
        categories: [Category.mock],
        selectedCategory: selectedCategory,
        onSelect: { selectedCategory = $0 }
    )
    .padding()
}
