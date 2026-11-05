import SwiftUI

struct OrderStatusBadge: View {
    let status: String
    private var tint: Color {
        switch status {
        case "Paid", "Delivered": AppColors.success
        case "Cancelled": AppColors.error
        case "Pending": AppColors.textSecondary
        default: AppColors.primary
        }
    }
    var body: some View {
        Text(Order.deliveryLabel(for: status))
            .font(AppFonts.footnote.weight(.semibold))
            .padding(.horizontal, 12).padding(.vertical, 7)
            .foregroundStyle(tint)
            .background(tint.opacity(0.10), in: Capsule())
            .accessibilityLabel("Order status: \(Order.deliveryLabel(for: status))")
    }
}

enum DisplayDate {
    static func string(_ value: String) -> String {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = fractional.date(from: value) ?? ISO8601DateFormatter().date(from: value)
        return date?.formatted(date: .abbreviated, time: .shortened) ?? value
    }
}
