import SwiftUI

struct ProductDetails: View {

    @State private var viewModel: ProductDetailsViewModel
    let productID: String
    init(viewModel: ProductDetailsViewModel,productID: String) {
        _viewModel = State(initialValue: viewModel)
        self.productID = productID
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

                        PrimaryButton(
                            title: "Add to Cart",
                            isEnabled: product.stock! > 0
                        ) {
                            // Add to cart later
                        }
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
                    // Retry later
                }

            } else {
                StateView(
                    imageName: "shippingbox", imageColor: AppColors.primary,
                    title: nil,
                    message: "Product not found",
                    buttonTitle: "Try Again"
                ) {
                    // Retry later
                }
            }
        }
        .task {
                await viewModel.fetchProductDetails(id: productID)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sections

private extension ProductDetails {

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

            Text(product.brand)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)

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

            Text(product.description!)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    func variantsSection(product: Product) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {

            Text("Variants")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(
                product.variants!,
                id: \.self
            ) { variant in

                Text(
                    "\(variant.size) - \(variant.color)"
                )
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    func stockSection(product: Product) -> some View {
        HStack(
            spacing: AppSpacing.xs
        ) {

            Image(
                systemName: product.stock! > 0
                    ? "checkmark.circle.fill"
                    : "xmark.circle.fill"
            )
            .foregroundStyle(
                product.stock! > 0
                    ? AppColors.success
                    : AppColors.error
            )

            Text(
                product.stock! > 0
                    ? "In Stock"
                    : "Out of Stock"
            )
            .font(AppFonts.body)
            .foregroundStyle(AppColors.textSecondary)
        }
    }
}

#Preview {
    ProductDetails(
        viewModel: AppContainer.shared
            .makeProductDetailsViewModel(), productID: "6a64d5f6261b104aebdacb0c"
    )
}
