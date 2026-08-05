//
//  APIClient.swift
//  Cartify
//
//  Created by Soha Elgaly on 21/07/2026.
//
/// Executes network requests and decodes server responses.
import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL : URL
    init(session: URLSession) {
        self.session = session
        self.decoder = JSONDecoder()
        self.baseURL = URL(string: "https://cartify-backend-production-eced.up.railway.app/api")!
    }
    
    func send<T: Decodable>(endPoint: EndPoint) async throws -> T {
        //Build the URL
         let url = baseURL.appendingPathComponent(endPoint.path)
        let data: Data
        let response: URLResponse
        //Create the request
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.headers
        request.httpBody = endPoint.body
        
        
        do {
            (data,response) = try await session.data(for: request)
        } catch  {
            throw NetworkError.transport(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode:httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
            
        } catch  {
            throw NetworkError.decoding(error)
        }
        
    }
    
    
}














/* Base URL
 https://api.cartify.com/api/v1

 Authentication
 POST /auth/register
 POST /auth/login
 POST /auth/refresh

 Products
 GET /products
 GET /products/{id}

 Categories
 GET /categories

 Wishlist
 GET /wishlist
 POST /wishlist
 DELETE /wishlist/{productId}

 Cart
 GET /cart
 POST /cart/items
 PATCH /cart/items/{id}
 DELETE /cart/items/{id}

 Orders
 POST /orders
 GET /orders
 GET /orders/{id}

 Coupons
 POST /coupons/apply

 Profile
 GET /profile
 PATCH /profile
 */
