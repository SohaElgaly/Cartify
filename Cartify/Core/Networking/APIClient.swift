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

            if httpResponse.statusCode == 401,
               endPoint.requiresAuthentication, !hasRetried {

                if let apiError = try? decoder.decode(APIError.self, from: data),
                   apiError.error.code == "TOKEN_EXPIRED" {
                    do {
                        try await refreshAccessToken()
                        
                        return try await send(endPoint: endPoint,hasRetried: true)
                    } catch {
                        try? authSession.logout()
                        throw error
                    }
                }
            }

            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
            do {
                return try decoder.decode(T.self, from: data)
                
            } catch  {
                throw NetworkError.decoding(error)
            }
            
        }
        
    private func refreshAccessToken() async throws {
        
        
        guard let refreshToken = try tokenStorage.getRefreshToken() else {
            throw NetworkError.missingRefreshToken
        }
        
        let data: Data
        let response: URLResponse
        let endpoint = AuthEndpoint.refreshToken(refreshToken)
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body
        
        do {
            (data,response) = try await session.data(for: request)
        } catch  {
            throw NetworkError.transport(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
               throw NetworkError.serverError(
                   statusCode: httpResponse.statusCode
               )
           }
        
        do {
            let apiResponse = try decoder.decode(APIResponse<AuthData>.self, from: data)
            try tokenStorage.save(accessToken: apiResponse.data.accessToken, refreshToken: apiResponse.data.refreshToken)
        } catch  {
            throw NetworkError.decoding(error)
        }
    }
}
