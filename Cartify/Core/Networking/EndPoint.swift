//
//  EndPoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 21/07/2026.
//

import Foundation

protocol EndPoint {
    
    var path: String {get}
    var method: HTTPMethod {get}
    var queryItems:[URLQueryItem] {get}
    var headers:[String: String] {get}
    var body: Data? {get}
}


extension EndPoint {
    var queryItems:[URLQueryItem] {
        []
    }
    var headers:[String: String] {
        [:]
    }
    var body: Data? {
        nil
    }
}
