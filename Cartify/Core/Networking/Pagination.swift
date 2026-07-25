//
//  Pagination.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import Foundation
struct Pagination: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
}
