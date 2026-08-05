//
//  StateView.swift
//  Cartify
//
//  Created by Soha Elgaly on 01/08/2026.
//

import SwiftUI

struct StateView: View {

    let imageName: String
    let imageColor: Color
    let title: String?
    let message: String
    let buttonTitle: String?
    let actionButton: (() -> Void)?

    var body: some View {

        VStack(spacing: AppSpacing.medium) {

            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundStyle(imageColor)

            if let title {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if let buttonTitle {
                Button(buttonTitle) {
                    actionButton?()
                }
                .font(AppFonts.bodyMedium)
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.large)
                .padding(.vertical, AppSpacing.small)
                .background(AppColors.primary)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#Preview {
    StateView(imageName: "shippingbox", imageColor: .orange,title: nil,message: "Something went wrong, Please try again",buttonTitle: "Try Again", actionButton: {})
}
