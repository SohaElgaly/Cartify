//
//  ProductCategory.swift
//  Cartify
//
//  Created by Soha Elgaly on 28/07/2026.
//

import Foundation

struct ProductCategory: Decodable,Identifiable {
    let id: String
    let name: String
    let image: String?
    
    
    enum CodingKeys:String, CodingKey {
        case id = "_id"
        case name
        case image
    }
}

extension ProductCategory {
    static let mock = ProductCategory(id: "234", name: "Adidas", image: nil)
}
