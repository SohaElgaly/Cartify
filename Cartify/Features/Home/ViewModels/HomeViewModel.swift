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
    private(set) var products: [Product] = []
    private let repository: ProductRepository
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    
    func loadProducts() async {
        do {
          products = try await repository.fetchProducts()
        } catch {
            
        }
    }
}
