//
//  Product.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/07/2026.
//

import Foundation

struct Product: Decodable, Identifiable {

    let id: String
    let title: String
    let description: String?

    let price: Double
    let discountPrice: Double?

    let stock: Int?
    let rating: Double
    let reviewCount: Int

    let brand: String

    let categoryId: ProductCategory

   let images: [String]?
   let variants: [Variant]?

    let createdAt: String?
    let updatedAt: String?
}

extension Product {

    static let mock = Product(
        id: "1",
        title: "Apple AirPods Pro (2nd Gen)",
        description: "Active noise cancellation with Adaptive Transparency.",
        price: 249,
        discountPrice: 219,
        stock: 25,
        rating: 4.8,
        reviewCount: 512,
        brand: "Apple",
        categoryId: .mock,
        images: [],
        variants: [],
        createdAt: "",
        updatedAt: ""
    )
}
