//
//  CheckoutRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 19/10/2026.
//

import Foundation

protocol CheckoutRepository {
    func createOrder(request: CheckoutRequest) async throws -> CheckoutResponse
    func payOrder(orderId: String) async throws -> PaymentResponse
}
