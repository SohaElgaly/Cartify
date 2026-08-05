//
//  NetworkImage.swift
//  Cartify
//
//  Created by Soha Elgaly on 04/08/2026.
//

import SwiftUI


struct NetworkImage: View {
    
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        LoadingView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Valid URL") {
    NetworkImage(url: URL(string: "https://picsum.photos/300"))
        .frame(width: 160, height: 120)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        .padding()
        .background(AppColors.background)
}
#Preview("Invalid URL") {
    NetworkImage(url: URL(string: "https://invalid.example.com/image.png"))
        .frame(width: 160, height: 120)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        .padding()
        .background(AppColors.background)
}

#Preview("Nil URL") {
    NetworkImage(url: nil)
        .frame(width: 160, height: 120)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        .padding()
        .background(AppColors.background)
}

