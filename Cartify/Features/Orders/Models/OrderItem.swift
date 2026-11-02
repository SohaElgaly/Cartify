//
//  OrderItem.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

struct OrderItem : Decodable {
    let productId: String
    let title: String
    let image: String
    let price: Double
    let quantity: Int
    let subtotal: Double
}
