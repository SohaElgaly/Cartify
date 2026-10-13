//
//  AddCartItemRequest.swift
//  Cartify
//
//  Created by Soha Elgaly on 08/10/2026.
//

import Foundation

struct AddCartItemRequest: Encodable {
    let productId: String
    let quantity: Int
}
