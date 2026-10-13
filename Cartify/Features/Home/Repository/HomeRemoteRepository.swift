//
//  HomeRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 27/07/2026.
//

import Foundation

final class HomeRemoteRepository: HomeRepository {
    
    private let apiClient :APIClient
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    func fetchHome() async throws -> HomeResponse {
        let response:APIResponse<HomeResponse> = try await apiClient.send(endPoint: HomeEndpoint.home)
        return response.data
    }
}
