//
//  CartRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/10/2026.
//

import Foundation

final class CartRemoteRepository: CartRepository {

    private let apiClient :APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    
    func fetchCart() async throws -> CartResponse {
        let response:APIResponse<CartResponse> = try await apiClient.send(endPoint: CartEndpoint.cart)
        return response.data
    }
    
    func addItem(productId: String, quantity: Int) async throws -> CartResponse {
        let response:APIResponse<CartResponse> = try await apiClient.send(endPoint: CartEndpoint.addItem(productId: productId, quantity: quantity))
        return response.data
    }
    
    func updateItem(productId: String, quantity: Int) async throws -> CartResponse {
        let response:APIResponse<CartResponse> = try await apiClient.send(endPoint: CartEndpoint.updateQuantity(productId: productId, quantity: quantity))
        return response.data
    }
    
    func removeItem(productId: String) async throws -> CartResponse {
        let response:APIResponse<CartResponse> = try await apiClient.send(endPoint: CartEndpoint.removeItem(productId: productId))
        return response.data
            
    }
 
}
