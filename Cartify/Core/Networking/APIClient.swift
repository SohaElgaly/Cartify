//
//  APIClient.swift
//  Cartify
//
//  Created by Soha Elgaly on 21/07/2026.
//

import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL : URL
    private let tokenStorage: TokenStorage
    private let authSession: AuthSession
    init(session: URLSession,tokenStorage: TokenStorage,authSession:AuthSession) {
        self.session = session
        self.decoder = JSONDecoder()
        self.baseURL = URL(string: "https://cartify-backend-production-c8f2.up.railway.app")!
        self.tokenStorage = tokenStorage
        self.authSession = authSession
    }
    
    func send<T: Decodable>(endPoint: EndPoint,hasRetried:Bool=false) async throws -> T {
        let url = baseURL.appendingPathComponent(endPoint.path)
        let data: Data
        let response: URLResponse
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        request.httpBody = endPoint.body
        if endPoint.requiresAuthentication {
            guard let accessToken = try tokenStorage.getAccessToken() else {
                throw NetworkError.missingAccessToken
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        
        do {
            (data,response) = try await session.data(for: request)
        } catch  {
            throw NetworkError.transport(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("🚨 HTTP STATUS:", httpResponse.statusCode)

            if let responseBody = String(data: data, encoding: .utf8) {
                print("🚨 RESPONSE BODY:", responseBody)
            }
            if httpResponse.statusCode == 401,
               endPoint.requiresAuthentication, !hasRetried {

                if let apiError = try? decoder.decode(APIError.self, from: data),
                   apiError.errorCode == "TOKEN_EXPIRED" {
                    print("🔄 Access token expired")
                    print("🔄 Trying to refresh access token...")
                    do {
                        try await refreshAccessToken()
                    } catch {
                        print("❌ Refresh failed:", error)

                        if shouldEndSession(afterRefreshError: error) {
                           try authSession.invalidateSession()
                        }

                        throw error
                    }

                    print("✅ Access token refreshed")
                    print("🔁 Retrying original request...")

                    return try await send(
                        endPoint: endPoint,
                        hasRetried: true
                    )
                }
            }

            if let apiError = try? decoder.decode(APIError.self, from: data) {
                if httpResponse.statusCode == 401,
                   endPoint.requiresAuthentication,
                   apiError.errorCode == "USER_NOT_FOUND" {
                    try authSession.invalidateSession()
                }

                throw NetworkError.apiError(
                    statusCode: httpResponse.statusCode,
                    message: apiError.message,
                    code: apiError.errorCode
                )
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
            do {
                return try decoder.decode(T.self, from: data)
            } catch  {
                throw NetworkError.decoding(error)
            }
            
        }
    private func shouldEndSession(afterRefreshError error: Error) -> Bool {
        guard let networkError = error as? NetworkError else {
            return false
        }

        switch networkError {
        case .missingRefreshToken:
            return true

        case .apiError(let statusCode, _, let code):
            return statusCode == 401 &&
                ["TOKEN_EXPIRED", "INVALID_TOKEN", "USER_NOT_FOUND"]
                    .contains(code)

        default:
            return false
        }
    }
    private func refreshAccessToken() async throws {
        
        guard let refreshToken = try tokenStorage.getRefreshToken() else {
            throw NetworkError.missingRefreshToken
        }
        
        let response: APIResponse<RefreshTokenData> =  try await send(endPoint: AuthEndpoint.refreshToken(refreshToken))
        
        try tokenStorage.save(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
    }
}
