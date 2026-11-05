//
//  AddressesViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 17/10/2026.
//

import Foundation
@Observable
@MainActor
final class AddressesViewModel  {
    private(set) var addresses: [Address] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var deletingAddressID: String?
    private(set) var actionErrorMessage: String?
    private let repository: AddressesRepository
    init(repository: AddressesRepository) {
        self.repository = repository
    }
    func fetchAddresses() async {
            guard !isLoading, deletingAddressID == nil else { return }

            errorMessage = nil
            isLoading = true

            defer {
                isLoading = false
            }

            do {
                addresses = try await repository.fetchAddresses()
                hasLoaded = true
                actionErrorMessage = nil
            } catch is CancellationError {
                return
            } catch NetworkError.transport(let error)
                where (error as? URLError)?.code == .cancelled {
                return
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    func deleteAddress(id: String) async {
        guard !isLoading, deletingAddressID == nil else { return }

        actionErrorMessage = nil
        deletingAddressID = id

        defer {
            deletingAddressID = nil
        }

        do {
            try await repository.deleteAddress(id: id)
        } catch {
            actionErrorMessage = error.localizedDescription
            return
        }

        addresses.removeAll { $0.id == id }

        do {
            addresses = try await repository.fetchAddresses()
            hasLoaded = true
        } catch {
            actionErrorMessage =
                "Address deleted, but the list couldn't be refreshed. Please refresh."
        }
    }
}
