import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let cartViewModel: CartViewModel
    let onCartTapped: () -> Void
    let onProfileTapped: () -> Void

    init(viewModel: HomeViewModel, cartViewModel: CartViewModel, onCartTapped: @escaping () -> Void,
         onProfileTapped: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.cartViewModel = cartViewModel
        self.onCartTapped = onCartTapped
        self.onProfileTapped = onProfileTapped
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    header
                    HomeSearchBar(searchText: $viewModel.searchText)

                    if !viewModel.isFiltering {
                        hero {
                            withAnimation { proxy.scrollTo("products", anchor: .top) }
                        }
                    }

                    categoryFilters
                    cartStatus
                    productContent
                        .id("products")
                }
                .padding(AppSpacing.medium)
                .padding(.bottom, AppSpacing.medium)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable { await viewModel.loadHome() }
        }
        .background(AppColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if !viewModel.hasLoaded { await viewModel.loadHome() }
        }
        .task {
            if cartViewModel.cart == nil { await cartViewModel.fetchCart() }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("CARTIFY")
                    .font(AppFonts.captionMedium)
                    .tracking(4)
                    .foregroundStyle(AppColors.primary)
                Text("Find your next favorite.")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Spacer(minLength: AppSpacing.small)
            Button(action: onProfileTapped) {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .frame(width: 48, height: 48)
                    .background(AppColors.cardBackground, in: Circle())
            }
            .tint(AppColors.textPrimary)
            .accessibilityLabel("Open profile")
        }
    }

    private func hero(onExplore: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack {
                Label("THE EVERYDAY EDIT", systemImage: "sparkles")
                    .font(AppFonts.footnote)
                    .tracking(1.5)
                Spacer()
                Image(systemName: "bag")
                    .font(.system(size: 32, weight: .light))
                    .accessibilityHidden(true)
            }
            Text("Little finds.\nBig possibilities.")
                .font(AppFonts.largeTitle)
                .fixedSize(horizontal: false, vertical: true)
            Text("Discover something that fits your day.")
                .font(AppFonts.caption)
                .foregroundStyle(.white.opacity(0.85))
            Button(action: onExplore) {
                HStack {
                    Text("Explore the edit")
                    Image(systemName: "arrow.down")
                }
                .font(AppFonts.captionMedium)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, 12)
                .foregroundStyle(AppColors.primaryDark)
                .background(.white, in: Capsule())
            }
        }
        .foregroundStyle(.white)
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [AppColors.primaryDark, AppColors.primary],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var categoryFilters: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Browse by category").font(AppFonts.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.small) {
                    categoryChip("All", id: nil)
                    ForEach(viewModel.categories) { category in
                        categoryChip(category.name, id: category.id)
                    }
                }
            }
        }
    }

    private func categoryChip(_ name: String, id: String?) -> some View {
        let selected = viewModel.selectedCategoryID == id
        return Button {
            viewModel.selectedCategoryID = id
        } label: {
            Text(name)
                .font(AppFonts.captionMedium)
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: 44)
                .foregroundStyle(selected ? .white : AppColors.textPrimary)
                .background(selected ? AppColors.primary : AppColors.cardBackground, in: Capsule())
                .overlay(Capsule().stroke(selected ? Color.clear : AppColors.border))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder
    private var productContent: some View {
        if viewModel.isLoading && !viewModel.hasLoaded {
            LoadingView(message: "Finding your next favorites…")
                .frame(minHeight: 180)
        } else if let error = viewModel.errorMessage {
            StateView(imageName: "wifi.exclamationmark", imageColor: AppColors.primary,
                      title: "Couldn't refresh your picks", message: error,
                      buttonTitle: "Try Again") {
                Task { await viewModel.loadHome() }
            }
            .padding(.vertical, AppSpacing.large)
        } else if viewModel.isFiltering {
            sectionHeading("Your results", subtitle: "Matches from the products featured on Home")
            if viewModel.filteredProducts.isEmpty {
                StateView(imageName: "magnifyingglass", imageColor: AppColors.primary,
                          title: "No matches here", message: "Try another search or category.",
                          buttonTitle: "Clear filters") {
                    viewModel.searchText = ""
                    viewModel.selectedCategoryID = nil
                }
                .padding(.vertical, AppSpacing.large)
            } else {
                productGrid(viewModel.filteredProducts)
            }
        } else {
            if !viewModel.newArrivals.isEmpty {
                sectionHeading("Just landed", subtitle: "Meet the new arrivals")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: AppSpacing.medium) {
                        ForEach(viewModel.newArrivals) { product in
                            productLink(product).frame(width: 190)
                        }
                    }
                }
            }
            if !viewModel.featuredProducts.isEmpty {
                sectionHeading("Picked for you", subtitle: "Explore our featured collection")
                productGrid(viewModel.featuredProducts)
            }
            if viewModel.featuredProducts.isEmpty && viewModel.newArrivals.isEmpty {
                StateView(imageName: "shippingbox", imageColor: AppColors.primary,
                          title: "More finds on the way", message: "Check back for new products.",
                          buttonTitle: "Refresh") {
                    Task { await viewModel.loadHome() }
                }
                .padding(.vertical, AppSpacing.large)
            }
            Button(action: onCartTapped) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "cart").font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your shopping bag").font(AppFonts.bodyMedium)
                        Text("Review your finds").font(AppFonts.caption)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(AppColors.textPrimary)
                .padding(AppSpacing.medium)
                .background(AppColors.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(AppFonts.title2).foregroundStyle(AppColors.textPrimary)
            Text(subtitle).font(AppFonts.caption).foregroundStyle(AppColors.textSecondary)
        }
    }

    private func productGrid(_ products: [Product]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: AppSpacing.medium)],
                  alignment: .leading, spacing: AppSpacing.medium) {
            ForEach(products) { product in productLink(product) }
        }
    }

    private func productLink(_ product: Product) -> some View {
        VStack(spacing: 0) {
            // The quantity buttons are outside the link, so they don't open details.
            NavigationLink {
                ProductDetails(viewModel: AppContainer.shared.makeProductDetailsViewModel(), productID: product.id, cartViewModel: cartViewModel)
            } label: {
                ProductCard(product: product)
            }
            .buttonStyle(.plain)

            quickAddControls(product)
                .padding(AppSpacing.small)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }

    @ViewBuilder
    private var cartStatus: some View {
        if let error = cartViewModel.errorMessage {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(error).font(AppFonts.caption).foregroundStyle(AppColors.error)
                Button("Refresh cart") {
                    Task { await cartViewModel.fetchCart() }
                }
                .disabled(cartViewModel.isLoading || cartViewModel.isUpdating)
            }
        } else if let message = cartViewModel.actionErrorMessage {
            Text(message).font(AppFonts.caption).foregroundStyle(AppColors.error)
        }
    }

    private func quickAddControls(_ product: Product) -> some View {
        let quantity = cartViewModel.quantity(for: product.id)
        let stock = cartViewModel.stock(for: product)
        let busy = cartViewModel.updatingProductID == product.id

        return Group {
            if quantity == 0 {
                Button {
                    Task { await cartViewModel.addItem(productId: product.id) }
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        if busy || cartViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "plus")
                        }
                        Text(stock == nil ? "Unavailable" : ((stock ?? 0) <= 0 ? "Out of stock" : "Quick add"))
                            .font(AppFonts.captionMedium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .foregroundStyle(.white)
                    .background(AppColors.primary, in: RoundedRectangle(cornerRadius: AppCornerRadius.small))
                }
                .buttonStyle(.plain)
                .disabled(!cartViewModel.canChangeCart || (stock ?? 0) <= 0)
                .opacity(cartViewModel.canChangeCart && (stock ?? 0) > 0 ? 1 : 0.55)
                .accessibilityLabel("Add \(product.title) to cart")
            } else {
                HStack(spacing: 0) {
                    Button {
                        Task {
                            if quantity == 1 {
                                await cartViewModel.removeItem(productId: product.id)
                            } else {
                                await cartViewModel.updateQuantity(productId: product.id, quantity: quantity - 1)
                            }
                        }
                    } label: {
                        Image(systemName: quantity == 1 ? "trash" : "minus")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(quantity == 1 ? "Remove \(product.title) from cart" : "Decrease quantity of \(product.title)")

                    Spacer(minLength: 0)
                    if busy {
                        ProgressView().accessibilityLabel("Updating quantity")
                    } else {
                        Text("\(quantity)")
                            .font(AppFonts.bodyMedium).monospacedDigit()
                            .accessibilityLabel("\(quantity) in cart")
                    }
                    Spacer(minLength: 0)

                    Button {
                        Task {
                            await cartViewModel.updateQuantity(productId: product.id, quantity: quantity + 1)
                        }
                    } label: {
                        Image(systemName: "plus").frame(width: 44, height: 44)
                    }
                    .disabled(quantity >= (stock ?? 0))
                    .accessibilityLabel("Increase quantity of \(product.title)")
                }
                .buttonStyle(.borderless)
                .tint(AppColors.primary)
                .background(AppColors.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: AppCornerRadius.small))
                .disabled(!cartViewModel.canChangeCart)
            }
        }
    }
}

#if DEBUG
private struct HomePreviewRepository: HomeRepository {
    func fetchHome() async throws -> HomeResponse {
        HomeResponse(banners: [], categories: [
            Category(id: Product.mock.categoryId.id, name: Product.mock.categoryId.name,
                     image: nil, createdAt: nil, updatedAt: nil)
        ], featuredProducts: [.mock], newArrivals: [.mock])
    }
}

#Preview("Home") {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(repository: HomePreviewRepository()),
                 cartViewModel: CartViewModel(repository: CartPreviewRepository(cart: CartResponse(items: [], total: 0))),
                 onCartTapped: {}, onProfileTapped: {})
    }
}
#endif
