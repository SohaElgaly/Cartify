//
//  PrimaryButton.swift
//  Cartify
//
//  Created by Soha Elgaly on 04/08/2026.
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var action: () -> Void

    private enum Metrics {
        static let height: CGFloat = 48
    }

    private var backgroundColor: Color {
        (isEnabled && !isLoading) ? AppColors.primary : AppColors.primary.opacity(0.5)
    }

    var body: some View {
        Button {
            guard isEnabled && !isLoading else { return }
            action()
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                }
            }
            .font(AppFonts.bodyMedium)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.height)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .accessibilityLabel(title)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: AppSpacing.medium) {
        PrimaryButton(title: "Add to Cart") {
        }
        PrimaryButton(title: "Add to Cart", isEnabled: false) {}
        PrimaryButton(title: "Processing…", isLoading: true) {}
    }
    .padding()
    .background(AppColors.background)
}
