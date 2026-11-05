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


extension Order {
    var isConfirmed: Bool {
        ["Paid", "Processing", "Shipped", "Delivered"].contains(status)
            || (status == "Cancelled" && paidAt != nil)
    }

    static func deliveryLabel(for status: String) -> String {
        switch status {
        case "Paid": "Confirmed"
        case "Processing": "Preparing"
        case "Pending": "Not confirmed"
        default: status
        }
    }

    var deliveryStep: Int? {
        switch status {
        case "Paid": 0
        case "Processing": 1
        case "Shipped": 2
        case "Delivered": 3
        default: nil
        }
    }
}
