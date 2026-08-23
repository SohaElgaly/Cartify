//
//  ProductRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 05/08/2026.
//

import Foundation

final class ProductRemoteRepository: ProductRepository {
    
   private let apiClient: APIClient
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    func fetchProductDetails(id: String) async throws -> Product {
        let response:APIResponse<Product> = try await apiClient.send(endPoint: ProductEndpoint.productDetails(id: id))
        return response.data
    }
    

    
    
}
