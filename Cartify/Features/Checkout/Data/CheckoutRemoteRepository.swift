//
//  CheckoutRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 19/10/2026.
//

import Foundation

final class CheckoutRemoteRepository: CheckoutRepository {
  
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createOrder(request: CheckoutRequest) async throws -> CheckoutResponse {
        let response: APIResponse<CheckoutResponse> = try await apiClient.send(
            endPoint: CheckoutEndpoint.createOrder(request)
        )
        return response.data
    }
    func payOrder(orderId: String) async throws -> PaymentResponse {
        let response:APIResponse<PaymentResponse> = try await apiClient.send(endPoint: CheckoutEndpoint.payOrder(orderId: orderId))
        return response.data
    }
    
}
