//
//  ProductRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 05/08/2026.
//

import Foundation
protocol ProductRepository {
    func fetchProductDetails(id: String) async throws -> Product
}
