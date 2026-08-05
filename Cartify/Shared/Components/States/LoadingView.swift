//
//  LoadingView.swift
//  Cartify
//
//  Created by Soha Elgaly on 04/08/2026.
//

import SwiftUI


struct LoadingView: View {

    var message: String? = "Loading..."
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            ProgressView()
                .tint(AppColors.primary)

            if let message {
                Text(message)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Default") {
    LoadingView()
        .background(AppColors.background)
}
#Preview("Custom message") {
    LoadingView(message: "Fetching your cart…")
        .background(AppColors.background)
}

