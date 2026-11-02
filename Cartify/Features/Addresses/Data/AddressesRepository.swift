//
//  AddressesRepository.swift
//  Cartify
//
//  Created by Soha Elgaly on 13/10/2026.
//

import Foundation

protocol AddressesRepository {
  func fetchAddresses() async throws -> [Address]
    func fetchAddress(id: String) async throws -> Address
    func createAddress(request: CreateAddressRequest) async throws -> Address
    func updateAddress(id: String, request: UpdateAddressRequest) async throws -> Address
    func deleteAddress(id: String) async throws
}
