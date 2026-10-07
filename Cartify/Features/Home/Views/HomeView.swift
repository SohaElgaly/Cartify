//
//  HomeView.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct HomeView: View {
    
    @State private var viewModel: HomeViewModel
    @State private var logoutVM: LogoutViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: HomeViewModel, logoutVM: LogoutViewModel) {
        _viewModel = State(initialValue: viewModel)
        _logoutVM = State(initialValue: logoutVM)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading,
                               spacing: AppSpacing.large) {
                            
                            // Navigation Bar
                            HomeNavigationBar(
                                username: "Soha"
                            )
                            
                            // Search
                            HomeSearchBar(
                                searchText: Binding(
                                    get: { viewModel.searchText },
                                    set: { viewModel.searchText = $0 }
                                )
                            )
                            Button {
                                Task {
                                    await logoutVM.logout()
                                }
                            } label: {
                                HStack {
                                    if logoutVM.isLoading {
                                        ProgressView()
                                    }

                                    Text(logoutVM.isLoading ? "Logging out…" : "Logout")
                                }
                            }
                            .disabled(logoutVM.isLoading)

                            if let errorMessage = logoutVM.errorMessage {
                                Text(errorMessage)
                                    .foregroundStyle(AppColors.error)
                            }

                            
                            // Coupon
                            CouponBanner(
                                title: "Summer Sale",
                                subtitle: "Up to 50% OFF on selected products",
                                buttonTitle: "Shop Now",
                                onButtonTap: {
                                    
                                }
                            )
                            
                            // Categories
                            CategorySection(
                                title: "Categories",
                                categories:viewModel.categories,
                                selectedCategory: nil,
                                onSelect: { category in
                                    print(category)
                                }
                            )
                            
                            // Products Title
                            Text("Popular Products")
                                .font(AppFonts.title)
                                .foregroundStyle(AppColors.textPrimary)
                            
                            // Products
                            LazyVGrid(
                                columns: columns,
                                spacing: AppSpacing.medium
                            ) {
                                
                                ForEach(viewModel.filteredProducts) { product in
                                    NavigationLink {
                                        ProductDetails(
                                            viewModel: AppContainer.shared.makeProductDetailsViewModel(),
                                            productID: product.id
                                        )
                                    } label: {
                                        ProductCard(product: product)
                                    }
                                    
                                }
                            }
                        }
                               .padding(.horizontal, AppSpacing.medium)
                               .padding(.vertical, AppSpacing.medium)
                    }
                    
                }
            }
            .task {
                await viewModel.loadHome()
            }
            .navigationBarBackButtonHidden()
        }
       
    }
}

#Preview {
    HomeView(viewModel: AppContainer.shared.makeHomeViewModel(), logoutVM: AppContainer.shared.makeLogoutViewModel())
}
