//
//  OrdersEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation


enum OrdersEndpoint: EndPoint {
   
    case orders(page: Int, limit: Int)
   case order(id: String)
    
    var path: String {
        switch self {
        case .orders:
            return "api/orders"
        case .order(let id):
            return "api/orders/\(id)"
        }
    }
    var method: HTTPMethod {
        .get
    }
    
    var requiresAuthentication: Bool {
            true
        }
    var queryItems: [URLQueryItem] {
        switch self {
        case .orders(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .order:
            return []
        }
    }
    
    
}
