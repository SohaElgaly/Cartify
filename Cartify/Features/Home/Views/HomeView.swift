//
//  HomeView.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import SwiftUI

struct HomeView: View {
    
    @State private var viewModel: HomeViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
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
                                ProductCard(product: product)
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

#Preview {
    HomeView(viewModel: AppContainer().makeHomeViewModel())
}
