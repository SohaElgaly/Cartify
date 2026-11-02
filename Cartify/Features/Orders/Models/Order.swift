//
//  Order.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

struct Order: Decodable, Identifiable {
    
    let id:String
    let status: String
    let subtotal: Double
    let discount: Double
    let total: Double
    let coupon: OrderCoupon?
    let shippingAddress: OrderShippingAddress
    let items: [OrderItem]
    let paymentId: String?
    let paidAt: String?
    let createdAt: String
    enum CodingKeys: String, CodingKey {
            case id = "_id"
            case status
            case subtotal
            case discount
            case total
            case coupon
            case shippingAddress
            case items
            case paymentId
            case paidAt
            case createdAt
        }
}
