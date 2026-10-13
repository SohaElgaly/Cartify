import SwiftUI

struct CartView: View {
    @State private var viewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    private let onContinueShopping: (() -> Void)?

    init(viewModel: CartViewModel, onContinueShopping: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onContinueShopping = onContinueShopping
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.cart == nil {
                LoadingView(message: "Loading your cart…")
            } else if let message = viewModel.errorMessage {
                StateView(
                    imageName: "exclamationmark.triangle",
                    imageColor: AppColors.primary,
                    title: "Couldn't load your cart",
                    message: message,
                    buttonTitle: "Try Again"
                ) {
                    Task { await viewModel.fetchCart() }
                }
            } else if let cart = viewModel.cart {
                if cart.items.isEmpty {
                    StateView(
                        imageName: "cart",
                        imageColor: AppColors.primary,
                        title: "Your cart is empty",
                        message: "Explore products and find something you like.",
                        buttonTitle: "Continue Shopping",
                        actionButton: {
                            if let onContinueShopping { onContinueShopping() }
                            else { dismiss() }
                        }
                    )
                } else {
                    cartContent(cart)
                }
            } else {
                LoadingView(message: "Loading your cart…")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchCart() }
    }

    private func cartContent(_ cart: CartResponse) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text("\(cart.items.count) \(cart.items.count == 1 ? "product" : "products")")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                if viewModel.isUpdating {
                    ProgressView("Updating cart…")
                        .font(AppFonts.caption)
                        .tint(AppColors.primary)
                }

                if let message = viewModel.actionErrorMessage {
                    Text(message)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                }

                ForEach(cart.items) { item in
                    itemRow(item)
                }

                HStack {
                    Text("Total").font(AppFonts.headline)
                    Spacer()
                    // Display the server total instead of calculating it in the view.
                    PriceView(price: cart.total)
                }
                .padding(AppSpacing.medium)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            }
            .padding(AppSpacing.medium)
        }
        .refreshable { await viewModel.fetchCart() }
    }

    private func itemRow(_ item: CartItem) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            NetworkImage(url: item.images.first.flatMap(URL.init(string:)))
                .frame(width: 80, height: 80)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(item.title)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Quantity: \(item.quantity)")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                quantityControls(item)

                Button(role: .destructive) {
                    Task {
                        await viewModel.removeItem(productId: item.productId)
                    }
                } label: {
                    Label("Remove", systemImage: "trash")
                        .font(AppFonts.caption)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.error)
                .disabled(viewModel.isUpdating || viewModel.isLoading)
                .accessibilityLabel("Remove \(item.title) from cart")

                Text("Subtotal")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                PriceView(price: item.subtotal)

                if item.stock < item.quantity {
                    Text(item.stock <= 0 ? "Currently out of stock" : "Only \(item.stock) available")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                }
            }
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }

    private func quantityControls(_ item: CartItem) -> some View {
        HStack(spacing: AppSpacing.small) {
            Button {
                Task {
                    await viewModel.updateQuantity(
                        productId: item.productId,
                        quantity: item.quantity - 1
                    )
                }
            } label: {
                Image(systemName: "minus")
                    .frame(width: 44, height: 44)
            }
            .disabled(item.quantity <= 1)
            .accessibilityLabel("Decrease quantity of \(item.title)")

            Text("\(item.quantity)")
                .font(AppFonts.bodyMedium)
                .monospacedDigit()
                .accessibilityLabel("Quantity \(item.quantity)")

            Button {
                Task {
                    await viewModel.updateQuantity(
                        productId: item.productId,
                        quantity: item.quantity + 1
                    )
                }
            } label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
            }
            .disabled(item.quantity >= item.stock)
            .accessibilityLabel("Increase quantity of \(item.title)")
        }
        .buttonStyle(.bordered)
        .tint(AppColors.primary)
        .disabled(viewModel.isUpdating || viewModel.isLoading)
    }
}

#if DEBUG
// Previews never call the live cart API.
final class CartPreviewRepository: CartRepository {
    private var cart: CartResponse
    private let fails: Bool
    private let failsUpdates: Bool

    init(cart: CartResponse, fails: Bool = false, failsUpdates: Bool = false) {
        self.cart = cart
        self.fails = fails
        self.failsUpdates = failsUpdates
    }

    func fetchCart() async throws -> CartResponse {
        if fails { throw NetworkError.transport(URLError(.notConnectedToInternet)) }
        return cart
    }

    func addItem(productId: String, quantity: Int) async throws -> CartResponse {
        try await simulateUpdate()
        let existing = cart.items.first { $0.productId == productId }
        let product = Product.mock
        let newQuantity = (existing?.quantity ?? 0) + quantity
        let price = existing?.price ?? product.price
        let discount = existing?.discountPrice ?? product.discountPrice
        let item = CartItem(productId: productId, title: existing?.title ?? product.title,
                            price: price, discountPrice: discount,
                            images: existing?.images ?? [], stock: existing?.stock ?? product.stock ?? 0,
                            quantity: newQuantity, subtotal: (discount ?? price) * Double(newQuantity))
        return replaceItems(cart.items.filter { $0.productId != productId } + [item])
    }
    func updateItem(productId: String, quantity: Int) async throws -> CartResponse {
        try await simulateUpdate()
        let items = cart.items.map { item in
            guard item.productId == productId else { return item }
            return CartItem(
                productId: item.productId, title: item.title, price: item.price,
                discountPrice: item.discountPrice, images: item.images, stock: item.stock,
                quantity: quantity, subtotal: (item.discountPrice ?? item.price) * Double(quantity)
            )
        }
        return replaceItems(items)
    }
    func removeItem(productId: String) async throws -> CartResponse {
        try await simulateUpdate()
        return replaceItems(cart.items.filter { $0.productId != productId })
    }

    private func simulateUpdate() async throws {
        try await Task.sleep(for: .milliseconds(500))
        if failsUpdates {
            throw NetworkError.transport(URLError(.notConnectedToInternet))
        }
    }

    // Only the preview simulates server totals. The real view displays API values.
    private func replaceItems(_ items: [CartItem]) -> CartResponse {
        cart = CartResponse(items: items, total: items.reduce(0) { $0 + $1.subtotal })
        return cart
    }

    static let sample = CartResponse(items: [
        CartItem(productId: "sample", title: "Nike Air Max 90", price: 120,
                 discountPrice: 99, images: [], stock: 50, quantity: 2, subtotal: 198)
    ], total: 198)
}

#Preview("Cart — products") {
    NavigationStack {
        CartView(viewModel: CartViewModel(repository: CartPreviewRepository(cart: CartPreviewRepository.sample)))
    }
}

#Preview("Cart — empty") {
    NavigationStack {
        CartView(viewModel: CartViewModel(repository: CartPreviewRepository(cart: CartResponse(items: [], total: 0))))
    }
}

#Preview("Cart — error") {
    NavigationStack {
        CartView(viewModel: CartViewModel(repository: CartPreviewRepository(cart: CartResponse(items: [], total: 0), fails: true)))
    }
}

#Preview("Cart — update error") {
    NavigationStack {
        CartView(viewModel: CartViewModel(repository: CartPreviewRepository(
            cart: CartPreviewRepository.sample, failsUpdates: true
        )))
    }
}
#endif
