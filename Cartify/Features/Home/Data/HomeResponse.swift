//
//  HomeResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/07/2026.
//

import Foundation

struct HomeResponse: Decodable {
    let banners: [Banner]
    let categories: [Category]
    let featuredProducts: [Product]
    let newArrivals: [Product]
}
