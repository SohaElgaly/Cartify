//
//  CartEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/10/2026.
//

import Foundation

enum CartEndpoint : EndPoint {
    
    case cart
    case addItem(productId: String,quantity: Int)
    case updateQuantity(productId: String, quantity: Int)
    case removeItem(productId: String)
    var path: String {
        switch self {
        case .cart:
            return "api/cart"
        case .addItem:
            return "api/cart/items"
        case .updateQuantity(let productId, _):
            return "api/cart/items/\(productId)"
        case .removeItem(let productId):
            return "api/cart/items/\(productId)"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .cart:
            return .get
        case .addItem:
            return .post
        case .updateQuantity:
            return .patch
        case .removeItem:
            return .delete
        }
    }
    var requiresAuthentication: Bool {
        true
    }
    var headers: [String: String] {
            ["Content-Type": "application/json"]
        }

        var body: Data? {
            let encoder = JSONEncoder()

            switch self {
            case .cart, .removeItem:
                return nil

            case .addItem(let productId, let quantity):
                let request = AddCartItemRequest(
                    productId: productId,
                    quantity: quantity
                )

                return try? encoder.encode(request)

            case .updateQuantity(_, let quantity):
                let request = UpdateCartQuantityRequest(
                    quantity: quantity
                )

                return try? encoder.encode(request)
            }
        }
}
