//
//  CreateAddressRequest.swift
//  Cartify
//
//  Created by Soha Elgaly on 13/10/2026.
//

import Foundation
struct CreateAddressRequest: Encodable {
    let fullName: String
    let phone: String
    let country: String
    let city: String
    let addressLine: String
    let postalCode: String?
    let isDefault: Bool
}
