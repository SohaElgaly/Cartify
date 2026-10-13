//
//  HomeViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/07/2026.
//

import Foundation
import Observation
@MainActor
@Observable
final class HomeViewModel {
    private(set) var featuredProducts: [Product] = []
    private(set) var newArrivals: [Product] = []
    private(set) var categories: [Category] = []
    private(set) var banners: [Banner] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private let repository: HomeRepository
    var searchText = ""
    var selectedCategoryID: String?
    var isFiltering: Bool {
        selectedCategoryID != nil || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var filteredProducts: [Product] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var seen = Set<String>()
        // Home only contains featured products and new arrivals, not the entire catalog.
        return (featuredProducts + newArrivals).filter { product in
            guard seen.insert(product.id).inserted else { return false }
            let matchesCategory = selectedCategoryID == nil || product.categoryId.id == selectedCategoryID
            let matchesSearch = query.isEmpty || product.title.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
   
    func loadHome() async {
        guard !isLoading else { return }
        errorMessage = nil
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
            hasLoaded = true
            } catch is CancellationError {
                return
            } catch NetworkError.transport(let error) where (error as? URLError)?.code == .cancelled {
                return
            } catch {
             
                errorMessage = error.localizedDescription
            }
    }
}
