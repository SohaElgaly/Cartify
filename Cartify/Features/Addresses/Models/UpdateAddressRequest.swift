//
//  UpdateAddressRequest.swift
//  Cartify
//
//  Created by Soha Elgaly on 14/10/2026.
//

import Foundation

struct UpdateAddressRequest: Encodable {
        var fullName: String?
        var phone: String?
        var country: String?
        var city: String?
        var addressLine: String?
        var postalCode: String?
        var isDefault: Bool?
}
