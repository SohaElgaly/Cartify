//
//  OrderShippingAddress.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation

struct OrderShippingAddress: Decodable {
    let fullName: String
    let phone: String
    let country: String
    let city: String
    let addressLine: String
    let postalCode:String?
}
