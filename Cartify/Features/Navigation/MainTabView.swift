import SwiftUI

struct MainTabView: View {
    private enum Tab: Hashable {
        case home, cart, profile
    }

    @State private var selectedTab: Tab = .home
    @State private var cartViewModel: CartViewModel
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _cartViewModel = State(initialValue: container.makeCartViewModel())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    viewModel: container.makeHomeViewModel(),
                    cartViewModel: cartViewModel,
                    onCartTapped: { selectedTab = .cart },
                    onProfileTapped: { selectedTab = .profile }
                )
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Tab.home)

            NavigationStack {
                CartView(
                    viewModel: cartViewModel,
                    onContinueShopping: { selectedTab = .home }
                )
            }
            .tabItem { Label("Cart", systemImage: "cart") }
            .tag(Tab.cart)

            NavigationStack {
                ProfileView(logoutViewModel: container.makeLogoutViewModel())
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            .tag(Tab.profile)
        }
        .tint(AppColors.primary)
    }
}
