//
//  AddressesEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 13/10/2026.
//

import Foundation

enum AddressesEndpoint: EndPoint {
    case address(id: String)
    case addresses
    case createAddress(CreateAddressRequest)
    case updateAddress(id: String, request: UpdateAddressRequest)
    case deleteAddress(id: String)
    
    var method: HTTPMethod {
        switch self {
        case .addresses,.address:
            return .get
        case .createAddress:
            return .post
        case .updateAddress:
            return .patch
        case .deleteAddress:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .addresses,.createAddress:
            return "api/addresses"
        case .address(let id),.updateAddress(let id, _),.deleteAddress(let id):
            return "api/addresses/\(id)"
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
    var headers: [String: String] {
            ["Content-Type": "application/json"]
        }
    
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .createAddress(let request):
            return try? encoder.encode(request)
        case .updateAddress(_ , let request):
            return try? encoder.encode(request)
        case .addresses,.address,.deleteAddress:
            return nil
        }
    }
}
