//
//  ProductEndPoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 23/07/2026.
//

import Foundation

enum ProductEndPoint: EndPoint {
    
    case products
    case product(id: Int)
    
    var path : String {
        switch self {
        case .products:
            return "/products"
        case .product(let id):
            return "/products/\(id)"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .products,.product:
            return .get
        }
    }
}
