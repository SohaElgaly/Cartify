//
//  ProductEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 05/08/2026.
//

import Foundation
enum ProductEndpoint: EndPoint {
    case productDetails(id: String)
    var path: String {
        switch self {
        case .productDetails(let id):
            "api/products/\(id)"
        }
    }
    var method: HTTPMethod {
        .get
    }
}
