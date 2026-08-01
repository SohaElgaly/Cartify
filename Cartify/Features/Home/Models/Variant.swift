//
//  Variant.swift
//  Cartify
//
//  Created by Soha Elgaly on 26/07/2026.
//

import Foundation

struct Variant: Decodable, Identifiable {

    let id: String
    let size: String
    let color: String
    let stock: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case color
        case stock
    }
}
