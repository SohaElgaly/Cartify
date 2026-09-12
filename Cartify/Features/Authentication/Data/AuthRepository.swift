//
//  AuthRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 28/08/2026.
//

import Foundation

protocol AuthRepository {
    func login(request:LoginRequest) async throws -> AuthData
    func register(request: RegisterRequest) async throws -> AuthData
    func refreshToken(refreshToken:String) async throws -> AuthData
}
