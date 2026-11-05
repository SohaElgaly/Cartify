import Foundation
import Observation

@Observable
@MainActor
final class OrderDetailsViewModel {
    let orderID: String
    private(set) var order: Order?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var requiresVerification = true
    private let ordersRepository: OrdersRepository

    init(orderID: String, ordersRepository: OrdersRepository) {
        self.orderID = orderID
        self.ordersRepository = ordersRepository
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        requiresVerification = true
        defer { isLoading = false }
        do {
            try await readOrder()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func readOrder() async throws {
        let result = try await ordersRepository.fetchOrder(id: orderID)
        guard result.id == orderID else { throw NetworkError.invalidResponse }
        order = result
        requiresVerification = false
        if ["Paid", "Processing", "Shipped", "Delivered"].contains(result.status) {
            NotificationCenter.default.post(name: .orderPaymentCompleted, object: nil)
        }
    }
}

extension Notification.Name {
    static let orderPaymentCompleted = Notification.Name("Cartify.orderPaymentCompleted")
}
