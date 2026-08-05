//
//  HomeNavigationBar.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct HomeNavigationBar: View {
    let username: String
    var notificationsCount: Int = 0

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            // Leading: Greeting
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome")
                    .font(.headline)
                    .foregroundStyle(AppColors.textSecondary)
                Text(username)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: AppSpacing.medium)

            // Trailing: Notification button
            Button(action: {}) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.clear)
                        .contentShape(Circle())

                    if notificationsCount > 0 {
                        Text("\(min(notificationsCount, 99))")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AppColors.primary, in: Capsule())
                            .offset(x: 6, y: -6)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Notifications")
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        // Removed card style background, stroke, clip, and shadow as per instructions
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    VStack(spacing: 16) {
        HomeNavigationBar(username: "Soha", notificationsCount: 0)
        HomeNavigationBar(username: "Soha", notificationsCount: 7)
    }
    .padding()
    .background(Color(.systemBackground))
}
