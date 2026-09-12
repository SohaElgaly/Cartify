//
//  AppContainer.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/07/2026.
//

import Foundation

final class AppContainer {
    static let shared = AppContainer()
    private let session: URLSession
    private let tokenStorage: TokenStorage
    let apiClient : APIClient
    let homeRepository : HomeRepository
    let productRepository: ProductRepository
    let authRepository : AuthRepository
    let authSession : AuthSession
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.tokenStorage = TokenStorage()
        self.session = URLSession(configuration: configuration)
        self.authSession =  AuthSession(tokenStorage: tokenStorage)
        self.apiClient = APIClient(session: session, tokenStorage: tokenStorage, authSession: authSession)
        self.homeRepository = HomeRemoteRepository(apiClient: apiClient)
        self.productRepository = ProductRemoteRepository(apiClient: apiClient)
        self.authRepository = AuthRemoteRepository(apiClient: apiClient, tokenStorage: tokenStorage)
      
    }
   
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: homeRepository)
    }
    func makeProductDetailsViewModel() -> ProductDetailsViewModel {
        ProductDetailsViewModel(repository: productRepository)
    }
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(repository: authRepository, authSession: authSession)
    }
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(repository: authRepository, authSession: authSession)
    }
}
