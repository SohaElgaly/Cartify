//
//  NetworkError.swift
//  Cartify
//
//  Created by Soha Elgaly on 21/07/2026.
//

import Foundation


enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decoding(Error)
    case transport(Error)
}
