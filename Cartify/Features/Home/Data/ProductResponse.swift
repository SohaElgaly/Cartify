//
//  ProductResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import Foundation
struct ProductsResponse: Decodable {
    let products: [Product]
    let pagination: Pagination
}
