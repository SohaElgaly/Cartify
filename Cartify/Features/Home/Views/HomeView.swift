import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var recentlyAdded: Set<String> = []
    @State private var showingCartNotice = false
    @State private var cartNotice = ""
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
                    offerBanners

                    categoryFilters
                    productContent
                        .id("products")
                }
                .padding(AppSpacing.large)
                .padding(.bottom, AppSpacing.medium)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable {
                await viewModel.loadHome()
                await cartViewModel.fetchCart()
            }
        }
        .background(AppColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Cart update", isPresented: $showingCartNotice) {
            Button("Open cart", action: onCartTapped)
            Button("OK", role: .cancel) { }
        } message: {
            Text(cartNotice)
        }
        .task {
            if !viewModel.hasLoaded { await viewModel.loadHome() }
        }
        .task {
            if cartViewModel.cart == nil { await cartViewModel.fetchCart() }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                let name = AppContainer.shared.authSession.currentUser?.firstName
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                Text(name.isEmpty ? "Welcome to Cartify" : "Welcome back, \(name)")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                Text("Find your everyday favorites")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Spacer(minLength: 0)
            Button(action: onProfileTapped) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .tint(AppColors.textPrimary)
            .accessibilityLabel("Open profile")
        }
    }

    @ViewBuilder
    private var offerBanners: some View {
        if !viewModel.banners.isEmpty && !viewModel.isFiltering {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.banners) { banner in
                        VStack(alignment: .leading, spacing: 10) {
                            NetworkImage(url: URL(string: banner.image))
                                .frame(height: 135)
                                .clipped()
                            if let title = banner.title, !title.isEmpty {
                                Text(title)
                                    .font(AppFonts.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 14)
                            }
                        }
                        .frame(width: 285, alignment: .leading)
                        .background(AppColors.primaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            .accessibilityLabel("Offers")
        } else if !viewModel.isFiltering, let product = (viewModel.featuredProducts + viewModel.newArrivals).first(where: {
            guard let discounted = $0.discountPrice else { return false }
            return discounted >= 0 && discounted < $0.price
        }) {
            NavigationLink {
                ProductDetails(viewModel: AppContainer.shared.makeProductDetailsViewModel(), productID: product.id, cartViewModel: cartViewModel)
            } label: {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("A GOOD FIND, FOR LESS")
                            .font(AppFonts.footnote.weight(.semibold))
                            .tracking(1)
                        Text(product.title).font(AppFonts.title2).lineLimit(2)
                        PriceView(price: product.price, discountedPrice: product.discountPrice)
                        Label("Explore offer", systemImage: "arrow.right")
                            .font(AppFonts.captionMedium)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "tag")
                        .font(.system(size: 38, weight: .light))
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AppColors.textPrimary)
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primaryLight, in: RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)
        }
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
                .background(selected ? AppColors.action : AppColors.cardBackground, in: Capsule())
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
        let quantity = cartViewModel.quantity(for: product.id)
        let stockLimitReached = cartViewModel.stock(for: product).map { quantity >= $0 } ?? false

        return VStack(spacing: 0) {
            NavigationLink {
                ProductDetails(viewModel: AppContainer.shared.makeProductDetailsViewModel(), productID: product.id, cartViewModel: cartViewModel)
            } label: {
                ProductCard(product: product, showsPrice: false)
            }
            .buttonStyle(.plain)

            HStack(alignment: .center, spacing: 6) {
                PriceView(price: product.price, discountedPrice: product.discountPrice)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    guard cartViewModel.canChangeCart else {
                        cartNotice = "Your cart isn't available right now. Open Cart to try again. You can keep browsing products."
                        showingCartNotice = true
                        return
                    }
                    Task {
                        await cartViewModel.addItem(productId: product.id)
                        if cartViewModel.actionErrorMessage != nil {
                            cartNotice = "We couldn't confirm this update. Check your cart before adding the item again."
                            showingCartNotice = true
                        } else if cartViewModel.quantity(for: product.id) > quantity {
                            recentlyAdded.insert(product.id)
                            try? await Task.sleep(for: .seconds(1))
                            recentlyAdded.remove(product.id)
                        }
                    }
                } label: {
                    Group {
                        if cartViewModel.updatingProductID == product.id {
                            ProgressView()
                        } else {
                            Image(systemName: recentlyAdded.contains(product.id) ? "checkmark" : "cart.badge.plus")
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(AppColors.primaryLight, in: RoundedRectangle(cornerRadius: 10))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .tint(AppColors.primary)
                .disabled(recentlyAdded.contains(product.id) || cartViewModel.isLoading || cartViewModel.isUpdating || cartViewModel.isCheckingOut || stockLimitReached)
                .accessibilityLabel("Add \(product.title) to cart")
                .accessibilityValue(quantity > 0 ? "\(quantity) already in cart" : "Not in cart")
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
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
