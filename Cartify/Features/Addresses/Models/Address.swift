//
//  Address.swift
//  Cartify
//
//  Created by Soha Elgaly on 13/10/2026.
//

import Foundation

struct Address : Decodable , Identifiable {
    let id: String
        let fullName: String
        let phone: String
        let country: String
        let city: String
        let addressLine: String
        let postalCode: String?
        let isDefault: Bool

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case fullName
            case phone
            case country
            case city
            case addressLine
            case postalCode
            case isDefault
        }
}
