import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    private let session: AuthSession

    init(session: AuthSession) {
        self.session = session
    }

    var user: User? { session.currentUser }

    var fullName: String {
        guard let user else { return "" }
        return [user.firstName, user.lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var initials: String {
        guard let user else { return "" }
        return [user.firstName, user.lastName]
            .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}
