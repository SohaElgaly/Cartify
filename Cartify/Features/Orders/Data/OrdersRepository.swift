//
//  OrdersRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

protocol OrdersRepository {
    func fetchOrders(page:Int,limit:Int) async throws -> OrderResponse
    func fetchOrder(id: String) async throws -> Order
}
