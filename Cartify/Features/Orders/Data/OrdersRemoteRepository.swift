//
//  OrdersRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

final class OrdersRemoteRepository: OrdersRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchOrders(page: Int, limit: Int) async throws -> OrderResponse {
        let response: APIResponse<OrderResponse> = try await apiClient.send(endPoint: OrdersEndpoint.orders(page: page, limit: limit))
        return response.data
    }
    
    func fetchOrder(id: String) async throws -> Order {
        let response: APIResponse<Order> = try await apiClient.send(endPoint: OrdersEndpoint.order(id: id))
        return response.data
    }
    
}
