import SwiftUI

struct ProductDetails: View {

    @State private var viewModel: ProductDetailsViewModel
    private let cartViewModel: CartViewModel
    let productID: String
    init(viewModel: ProductDetailsViewModel, productID: String, cartViewModel: CartViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.productID = productID
        self.cartViewModel = cartViewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()

            } else if let product = viewModel.product {
                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: AppSpacing.large
                    ) {

                        imageSection(product: product)

                        productInfoSection(product: product)

                        descriptionSection(product: product)

                        variantsSection(product: product)

                        stockSection(product: product)

                        cartSection(product)
                    }
                    .padding(AppSpacing.medium)
                }

            } else if let errorMessage = viewModel.errorMessage {
                StateView(
                    imageName: "exclamationmark.triangle", imageColor: AppColors.primary,
                    title: nil,
                    message: errorMessage,
                    buttonTitle: "Try Again"
                ) {
                    Task {
                        await viewModel.fetchProductDetails(id: productID)
                    }
                }

            } else {
                StateView(
                    imageName: "shippingbox", imageColor: AppColors.primary,
                    title: nil,
                    message: "Product not found",
                    buttonTitle: "Try Again"
                ) {
                    Task {
                        await viewModel.fetchProductDetails(id: productID)
                    }
                }
            }
        }
        .task {
                await viewModel.fetchProductDetails(id: productID)
        }
        .background(AppColors.background)
        .task {
            if cartViewModel.cart == nil { await cartViewModel.fetchCart() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

// MARK: - Sections

private extension ProductDetails {

    func cartSection(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            if cartViewModel.isUpdating || cartViewModel.isLoading {
                ProgressView("Updating cart…")
            }
            if let error = cartViewModel.errorMessage {
                Text(error).font(AppFonts.caption).foregroundStyle(AppColors.error)
                Button("Refresh cart") {
                    Task { await cartViewModel.fetchCart() }
                }
                .disabled(cartViewModel.isUpdating || cartViewModel.isLoading)
            } else if let error = cartViewModel.actionErrorMessage {
                Text(error).font(AppFonts.caption).foregroundStyle(AppColors.error)
            }

            Text("In your cart: \(cartViewModel.quantity(for: product.id))")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)

            PrimaryButton(
                title: cartViewModel.quantity(for: product.id) > 0 ? "Add one more" : "Add to Cart",
                isEnabled: cartViewModel.canChangeCart &&
                    cartViewModel.quantity(for: product.id) < (cartViewModel.stock(for: product) ?? 0)
            ) {
                Task { await cartViewModel.addItem(productId: product.id) }
            }
        }
    }

    func imageSection(product: Product) -> some View {
        NetworkImage(
            url: product.images?.first.flatMap(URL.init(string:))
        )
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.medium
            )
        )
    }

    func productInfoSection(product: Product) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {

            if let brand = product.brand, !brand.isEmpty {
                Text(brand)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(product.title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)

            RatingView(
                rating: product.rating,
                reviewCount: product.reviewCount
            )

            PriceView(
                price: product.price,
                discountedPrice: product.discountPrice
            )
        }
    }

    func descriptionSection(product: Product) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {

            Text("Description")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(product.description ?? "No description available.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    @ViewBuilder
    func variantsSection(product: Product) -> some View {
        if let variants = product.variants, !variants.isEmpty {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                Text("Variants")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)

                ForEach(variants, id: \.self) { variant in
                    Text("\(variant.size) - \(variant.color)")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    func stockSection(product: Product) -> some View {
        if let stock = product.stock {
            HStack(spacing: AppSpacing.xs) {
                Image(
                    systemName: stock > 0
                        ? "checkmark.circle.fill"
                        : "xmark.circle.fill"
                )
                .foregroundStyle(
                    stock > 0
                        ? AppColors.success
                        : AppColors.error
                )

                Text(stock > 0 ? "In Stock" : "Out of Stock")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        } else {
            Text("Availability unavailable")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

#Preview {
    ProductDetails(
        viewModel: AppContainer.shared
            .makeProductDetailsViewModel(), productID: "6a64d5f6261b104aebdacb0c",
        cartViewModel: CartViewModel(repository: CartPreviewRepository(cart: CartResponse(items: [], total: 0)))
    )
}
