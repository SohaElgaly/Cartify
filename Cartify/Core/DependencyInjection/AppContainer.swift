//
//  AppContainer.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/07/2026.
//

import Foundation

final class AppContainer {
    private let session: URLSession
    let apiClient : APIClient
    let productRepository : ProductRepository
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: configuration)
        self.apiClient = APIClient(session: session)
        self.productRepository = RemoteProductRepository(apiClient: apiClient)
    }
   
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: productRepository)
    }
}
