//
//  ProductDetailsViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 05/08/2026.
//

import Foundation

@Observable
@MainActor
final class ProductDetailsViewModel {
    private let repository: ProductRepository
     var product: Product?
     var isLoading: Bool = false
     var errorMessage: String?

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func fetchProductDetails(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            product = try await repository.fetchProductDetails(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
