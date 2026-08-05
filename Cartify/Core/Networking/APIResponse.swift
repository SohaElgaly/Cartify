//
//  APIResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 25/07/2026.
//

import Foundation
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T
}
