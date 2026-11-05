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
    case apiError(statusCode: Int, message: String, code: String)
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

        case .apiError(_, let message, _):
            return message

        case .decoding(let error):
            #if DEBUG
            return "Decoding error: \(Self.decodingDiagnostic(error))"
            #else
            return "We couldn't read the server response. Please try again."
            #endif

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

extension NetworkError {
    /// Reports schema keys only, never response values or decoder debug descriptions.
    static func decodingDiagnostic(_ error: Error) -> String {
        func path(_ keys: [any CodingKey]) -> String {
            keys.isEmpty ? "root" : keys.map(\.stringValue).joined(separator: ".")
        }

        switch error {
        case DecodingError.keyNotFound(let key, let context):
            return "Missing field: \(path(context.codingPath + [key]))."
        case DecodingError.valueNotFound(_, let context):
            return "Unexpected null at: \(path(context.codingPath))."
        case DecodingError.typeMismatch(_, let context):
            return "Wrong value type at: \(path(context.codingPath))."
        case DecodingError.dataCorrupted(let context):
            return "Invalid data at: \(path(context.codingPath))."
        default:
            return "The response doesn't match the expected format."
        }
    }
}
