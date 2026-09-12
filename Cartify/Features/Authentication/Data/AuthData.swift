//
//  AuthData.swift
//  Cartify
//
//  Created by Soha Elgaly on 23/08/2026.
//

import Foundation

struct AuthData: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: User
}
