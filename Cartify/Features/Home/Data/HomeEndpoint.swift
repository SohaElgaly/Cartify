//
//  HomeEndpoint.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/07/2026.
//

import Foundation

enum HomeEndpoint: EndPoint {
 
    case home
    var path: String {
        switch self {
        case .home:
            return "/home"
        }
    }
    var method: HTTPMethod {
        .get
    }

}
