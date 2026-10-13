import Foundation
import Observation

@Observable
@MainActor
final class CartViewModel {
    private let repository: CartRepository
    private(set) var cart: CartResponse?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isUpdating = false
    private(set) var updatingProductID: String?
    private(set) var actionErrorMessage: String?

    var canChangeCart: Bool {
        cart != nil && !isLoading && !isUpdating && errorMessage == nil
    }

    init(repository: CartRepository) {
        self.repository = repository
    }

    func quantity(for productID: String) -> Int {
        cart?.items.first { $0.productId == productID }?.quantity ?? 0
    }

    func stock(for product: Product) -> Int? {
        cart?.items.first { $0.productId == product.id }?.stock ?? product.stock
    }

    func fetchCart() async {
        guard !isLoading, !isUpdating else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            cart = try await loadCart()
            actionErrorMessage = nil
        } catch is CancellationError {
            return
        } catch NetworkError.transport(let error)
            where (error as? URLError)?.code == .cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addItem(productId: String) async {
        await changeCart(productId: productId) {
            try await self.repository.addItem(productId: productId, quantity: 1)
        }
    }

    func updateQuantity(productId: String, quantity: Int) async {
        guard canChangeCart else { return }
        guard quantity >= 1 else {
            actionErrorMessage = "Quantity must be at least 1."
            return
        }
        await changeCart(productId: productId) {
            try await self.repository.updateItem(productId: productId, quantity: quantity)
        }
    }

    func removeItem(productId: String) async {
        await changeCart(productId: productId) {
            try await self.repository.removeItem(productId: productId)
        }
    }

    private func changeCart(
        productId: String,
        operation: () async throws -> CartResponse
    ) async {
        guard canChangeCart else { return }
        actionErrorMessage = nil
        updatingProductID = productId
        isUpdating = true
        defer {
            isUpdating = false
            updatingProductID = nil
        }

        do {
            cart = try await operation()
        } catch {
            let originalMessage = error.localizedDescription
            // A failed response doesn't prove the server rejected the change.
            // Read the current cart; never automatically repeat an additive POST.
            do {
                cart = try await loadCart()
                actionErrorMessage = "Cart refreshed. Check the quantity before trying again. \(originalMessage)"
            } catch {
                actionErrorMessage = originalMessage
                errorMessage = "Couldn't confirm your cart. Refresh it before making another change."
            }
        }
    }

    private func loadCart() async throws -> CartResponse {
        do {
            return try await repository.fetchCart()
        } catch NetworkError.apiError(let status, _, let code)
            where status == 404 && code == "CART_NOT_FOUND" {
            return CartResponse(items: [], total: 0)
        }
    }
}
