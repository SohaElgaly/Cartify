//
//  User.swift
//  Cartify
//
//  Created by Soha Elgaly on 23/08/2026.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let role : String
}
