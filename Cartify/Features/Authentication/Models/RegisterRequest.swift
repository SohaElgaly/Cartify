//
//  RegisterRequest.swift
//  Cartify
//
//  Created by Soha Elgaly on 23/08/2026.
//

import Foundation

struct RegisterRequest: Encodable {
    let firstName:String
    let lastName: String
    let email: String
    let password:String
    let phone: String?
}
