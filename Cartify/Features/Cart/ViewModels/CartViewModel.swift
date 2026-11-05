import Foundation
import Observation

@Observable
@MainActor
final class CartViewModel {
    private let repository: CartRepository
    private let productRepository: ProductRepository?
    private var productImages: [String: [String]] = [:]
    private(set) var cart: CartResponse?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isUpdating = false
    private(set) var updatingProductID: String?
    private(set) var actionErrorMessage: String?
    var isCheckingOut = false

    var canChangeCart: Bool {
        cart != nil && !isLoading && !isUpdating && !isCheckingOut && errorMessage == nil
    }

    init(repository: CartRepository, productRepository: ProductRepository? = nil) {
        self.repository = repository
        self.productRepository = productRepository
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
            cart = await resolvingImages(in: try await operation())
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

    // Cart metadata can omit photos; fetch only missing images from the same product.
    // Keep the server's quantities, stock and totals unchanged.
    private func resolvingImages(in response: CartResponse) async -> CartResponse {
        guard let productRepository else { return response }
        var items: [CartItem] = []
        for item in response.items {
            if item.images.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                items.append(item)
                continue
            }
            var images = productImages[item.productId] ?? []
            if images.isEmpty,
               let product = try? await productRepository.fetchProductDetails(id: item.productId) {
                images = product.images ?? []
                productImages[item.productId] = images
            }
            items.append(CartItem(productId: item.productId, title: item.title,
                                  price: item.price, discountPrice: item.discountPrice,
                                  images: images, stock: item.stock, quantity: item.quantity,
                                  subtotal: item.subtotal))
        }
        return CartResponse(items: items, total: response.total)
    }

    private func loadCart() async throws -> CartResponse {
        do {
            return await resolvingImages(in: try await repository.fetchCart())
        } catch NetworkError.apiError(let status, _, let code)
            where status == 404 && code == "CART_NOT_FOUND" {
            return CartResponse(items: [], total: 0)
        }
    }
}
