import SwiftUI

// Semantic styles scale with the user's preferred text size.
enum AppFonts {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .bold)
    static let title2 = Font.system(.title3, weight: .semibold)
    static let headline = Font.system(.headline, weight: .semibold)
    static let body = Font.system(.body)
    static let bodyMedium = Font.system(.body, weight: .medium)
    static let caption = Font.system(.subheadline)
    static let captionMedium = Font.system(.subheadline, weight: .semibold)
    static let footnote = Font.system(.footnote)
}
