//
//  AddressRemoteRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 13/10/2026.
//

import Foundation

final class AddressRemoteRepository: AddressesRepository {
  
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    func fetchAddresses() async throws -> [Address] {
        let response: APIResponse<[Address]> = try await apiClient.send(endPoint: AddressesEndpoint.addresses)
        return response.data
    }
    
    func fetchAddress(id: String) async throws -> Address {
        let response: APIResponse<Address> = try await apiClient.send(endPoint: AddressesEndpoint.address(id: id))
        return response.data
    }
    
    func createAddress(request: CreateAddressRequest) async throws -> Address {
        let response: APIResponse<Address> = try await apiClient.send(endPoint: AddressesEndpoint.createAddress(request))
        return response.data
    }
    
    func updateAddress(id: String, request: UpdateAddressRequest) async throws -> Address {
        let response: APIResponse<Address> = try await apiClient.send(endPoint: AddressesEndpoint.updateAddress(id: id, request: request))
        return response.data
    }
    
    func deleteAddress(id: String) async throws {
        let _: APIMessageResponse = try await apiClient.send(
                endPoint: AddressesEndpoint.deleteAddress(id: id))
        
    }
    
    
}
