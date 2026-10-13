//
//  CartItem.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/10/2026.
//

import Foundation

struct CartItem: Decodable, Identifiable {
    let productId: String
    let title: String
    let price: Double
    let discountPrice: Double?
    let images: [String]
    let stock: Int
    let quantity: Int
    let subtotal: Double

    var id: String {
        productId
    }
}
