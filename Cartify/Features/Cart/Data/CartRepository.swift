//
//  CartRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/10/2026.
//

import Foundation

protocol CartRepository {
    func fetchCart() async throws -> CartResponse
    func addItem(productId: String, quantity: Int) async throws -> CartResponse
    
    func updateItem(productId: String,quantity:Int) async throws -> CartResponse
    func removeItem(productId: String) async throws -> CartResponse
}
