//
//  RefreshTokenData.swift
//  Cartify
//
//  Created by Soha Elgaly on 01/10/2026.
//

import Foundation

struct RefreshTokenData: Decodable {
    let accessToken: String
    let refreshToken: String
}
