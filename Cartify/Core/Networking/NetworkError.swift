//
//  NetworkError.swift
//  Cartify
//
//  Created by Soha Elgaly on 21/07/2026.
//

import Foundation


enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decoding(Error)
    case transport(Error)
    case missingAccessToken
    case missingRefreshToken
    case authenticationError(code: String)
}

extension NetworkError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."

        case .invalidResponse:
            return "Invalid server response."

        case .serverError(let statusCode):
            return "Server error: \(statusCode)."

        case .decoding(let error):
            return "Decoding error: \(error.localizedDescription)"

        case .transport(let error):
            return "Network error: \(error.localizedDescription)"

        case .missingAccessToken:
            return "Missing access token."

        case .authenticationError(let code):
            return "Authentication error: \(code)"
        case .missingRefreshToken:
            return "Missing refresh token."
        }
    }
}
