//
//  Category.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import Foundation

struct Category: Decodable, Identifiable {

    let id: String
    let name: String
    let image: String?
    let createdAt: String?
    let updatedAt: String?
}

extension Category {

    static let mock = Category(
        id: "1",
        name: "Electronics",
        image: nil,
        createdAt: nil,
        updatedAt: nil
    )
}
