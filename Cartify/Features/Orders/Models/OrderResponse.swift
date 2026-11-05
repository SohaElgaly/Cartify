//
//  OrderResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

struct OrderResponse: Decodable {
    let orders: [Order]
    let pagination: Pagination
}
