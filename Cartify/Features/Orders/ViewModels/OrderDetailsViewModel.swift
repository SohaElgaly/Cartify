import Foundation
import Observation

@Observable
@MainActor
final class OrderDetailsViewModel {
    let orderID: String
    private(set) var order: Order?
    private(set) var isLoading = false
    private(set) var isPaying = false
    private(set) var errorMessage: String?
    private(set) var requiresVerification = true
    private let ordersRepository: OrdersRepository
    private let checkoutRepository: CheckoutRepository

    var canPay: Bool {
        order?.status == "Pending" && !requiresVerification && !isLoading && !isPaying
    }

    init(orderID: String, ordersRepository: OrdersRepository, checkoutRepository: CheckoutRepository) {
        self.orderID = orderID
        self.ordersRepository = ordersRepository
        self.checkoutRepository = checkoutRepository
    }

    func refresh() async {
        guard !isLoading, !isPaying else { return }
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

    func pay() async {
        guard canPay else { return }
        isPaying = true
        errorMessage = nil
        defer { isPaying = false }
        do {
            // Always check the current server status before a new payment attempt.
            requiresVerification = true
            try await readOrder()
            guard order?.status == "Pending" else { return }
            requiresVerification = true
            let payment = try await checkoutRepository.payOrder(orderId: orderID)
            guard payment.orderId == orderID, payment.status == "Paid" else {
                throw NetworkError.invalidResponse
            }
            NotificationCenter.default.post(name: .orderPaymentCompleted, object: nil)
            try await readOrder()
        } catch {
            let originalError = error.localizedDescription
            // GET is safe to repeat; never automatically repeat the payment POST.
            do {
                try await readOrder()
                if order?.status == "Pending" {
                    errorMessage = "The order is still Pending. You can retry payment. \(originalError)"
                }
            } catch {
                requiresVerification = true
                errorMessage = "Couldn't confirm the order status. Refresh before paying again."
            }
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
