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
    case forgotPassword(ForgotPasswordRequest)
    case resetPassword(ResetPasswordRequest)
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
        case .forgotPassword:
            "api/auth/forgot-password"
        case .resetPassword:
            "api/auth/reset-password"
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
        case .login, .register, .refreshToken,.forgotPassword,.resetPassword:
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
        case .resetPassword(let resquest):
            return try? encoder.encode(resquest)
        case .forgotPassword(let request):
            return try? encoder.encode(request)
        }
    }
    
}
