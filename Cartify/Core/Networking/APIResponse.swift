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

struct APIError: Decodable {
    let success: Bool
    let message: String
    let errorCode: String
}

struct ErrorDetail: Decodable {
    let code: String
}

struct APIMessageResponse: Decodable {
    let success: Bool
    let message: String
}
