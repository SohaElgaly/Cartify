//
//  ResetPasswordRequest.swift
//  Cartify
//
//  Created by Soha Elgaly on 15/09/2026.
//

import Foundation

struct ResetPasswordRequest: Encodable {
    let token: String
    let password:String

}
