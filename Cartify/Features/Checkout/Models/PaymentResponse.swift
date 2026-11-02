//
//  PaymentResponse.swift
//  Cartify
//
//  Created by Soha Elgaly on 19/10/2026.
//

import Foundation

struct PaymentResponse: Decodable {
    let orderId: String
    let paymentId: String
    let status: String
    let total: Double
    let paidAt: String
}
