//
//  RemoteProductRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/07/2026.
//

import Foundation

final class RemoteProductRepository: ProductRepository {
    private let apiClient: APIClient
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    func fetchProducts() async throws -> [Product] {
        let response: APIResponse<ProductsResponse> =
         try await apiClient.send(endPoint: ProductEndPoint.products)

       return response.data.products
    }
    
    
}
