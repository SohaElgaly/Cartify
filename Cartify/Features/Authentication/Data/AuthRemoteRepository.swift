//
//  AuthRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 28/08/2026.
//

import Foundation

final class AuthRemoteRepository: AuthRepository {
  
    
    private let apiClient: APIClient
    private let tokenStorage: TokenStorage
    
    init(apiClient: APIClient, tokenStorage: TokenStorage) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
    }
    func login(request: LoginRequest) async throws -> AuthData {
        let response: APIResponse<AuthData> =  try await apiClient.send(endPoint: AuthEndpoint.login(request))
        try tokenStorage.save(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
        return response.data
    }
    
    func register(request: RegisterRequest) async throws -> AuthData {
        let response: APIResponse<AuthData> =  try await apiClient.send(endPoint: AuthEndpoint.register(request))
        try tokenStorage.save(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
        return response.data
    }
    func refreshToken(refreshToken: String) async throws -> AuthData {
        let response: APIResponse<AuthData> =  try await apiClient.send(endPoint: AuthEndpoint.refreshToken(refreshToken))
        try tokenStorage.save(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
        return response.data
    }
    
    
}
