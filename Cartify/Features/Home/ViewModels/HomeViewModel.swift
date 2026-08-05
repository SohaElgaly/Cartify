//
//  HomeViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/07/2026.
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var featuredProducts: [Product] = []
    private(set) var newArrivals: [Product] = []
    private(set) var categories: [Category] = []
    private(set) var banners: [Banner] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private let repository: HomeRepository
    var searchText = ""
    var filteredProducts: [Product] {
        guard !searchText.isEmpty else {
            return featuredProducts
        }
        return featuredProducts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
   
    func loadHome() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let home = try await repository.fetchHome()
            banners = home.banners
            categories = home.categories 
            newArrivals = home.newArrivals
            featuredProducts = home.featuredProducts
            print(home)
            } catch {
             
                errorMessage = error.localizedDescription
            }
    }
}
