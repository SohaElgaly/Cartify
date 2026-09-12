//
//  AuthEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 24/08/2026.
//

import Foundation

enum AuthEndpoint: EndPoint {
    case login(LoginRequest)
    case register(RegisterRequest)
    case logout
    case refreshToken(String)
    var path: String {
        switch self {
        case .login:
             "api/auth/login"
        case .register:
             "api/auth/register"
        case .logout:
             "api/auth/logout"
        case .refreshToken:
             "api/auth/refresh-token"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    var headers: [String : String] {
        [
            "Content-Type": "application/json"
        ]
    }
    var requiresAuthentication: Bool {
        switch self {
        case .login, .register, .refreshToken:
            false
            
        case .logout:
            true
        }
    }
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .login(let request):
            return try? encoder.encode(request)
        case .register(let request):
            return try? encoder.encode(request)
        case .logout:
            return nil
        case .refreshToken(let refreshToken):
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            return try? encoder.encode(request)
        }
    }
    
}
