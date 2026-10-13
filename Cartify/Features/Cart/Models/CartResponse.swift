//
//  CartResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 07/10/2026.
//

import Foundation

struct CartResponse: Decodable {
    let items : [CartItem]
    let total: Double
}
