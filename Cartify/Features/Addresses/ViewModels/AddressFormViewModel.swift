import Foundation
import Observation

@Observable
@MainActor
final class AddressFormViewModel {
    var fullName: String
    var phone: String
    var country: String
    var city: String
    var addressLine: String
    var postalCode: String
    var isDefault: Bool

    private(set) var isSaving = false
    private(set) var errorMessage: String?
    private(set) var savedAddress: Address?

    private let repository: AddressesRepository
    private let originalAddress: Address?

    var isEditing: Bool { originalAddress != nil }

    init(repository: AddressesRepository, address: Address? = nil) {
        self.repository = repository
        originalAddress = address
        fullName = address?.fullName ?? ""
        phone = address?.phone ?? ""
        country = address?.country ?? ""
        city = address?.city ?? ""
        addressLine = address?.addressLine ?? ""
        postalCode = address?.postalCode ?? ""
        isDefault = address?.isDefault ?? false
    }

    // The view can close the form and reload the list only when this returns true.
    func saveAddress() async -> Bool {
        guard !isSaving, savedAddress == nil else { return false }
        errorMessage = nil

        let name = trimmed(fullName)
        let phoneNumber = trimmed(phone)
        let countryName = trimmed(country)
        let cityName = trimmed(city)
        let line = trimmed(addressLine)
        let postal = trimmed(postalCode)

        let requiredFields = [
            (name, "Recipient name"),
            (phoneNumber, "Phone number"),
            (countryName, "Country"),
            (cityName, "City"),
            (line, "Address")
        ]
        if let missingField = requiredFields.first(where: { $0.0.isEmpty }) {
            errorMessage = "\(missingField.1) is required."
            return false
        }

        // nil in a PATCH omits the field; it doesn't erase the saved postal code.
        // Until the API documents how to clear it, don't report a misleading success.
        if let oldPostal = originalAddress?.postalCode,
           !trimmed(oldPostal).isEmpty, postal.isEmpty {
            errorMessage = "Clearing an existing postal code isn't supported yet. Keep it or enter a new one."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            if let address = originalAddress {
                let request = UpdateAddressRequest(
                    fullName: name,
                    phone: phoneNumber,
                    country: countryName,
                    city: cityName,
                    addressLine: line,
                    postalCode: postal.isEmpty ? nil : postal,
                    isDefault: isDefault
                )
                savedAddress = try await repository.updateAddress(id: address.id, request: request)
            } else {
                let request = CreateAddressRequest(
                    fullName: name,
                    phone: phoneNumber,
                    country: countryName,
                    city: cityName,
                    addressLine: line,
                    postalCode: postal.isEmpty ? nil : postal,
                    isDefault: isDefault
                )
                savedAddress = try await repository.createAddress(request: request)
            }
            return true
        } catch NetworkError.transport(let error) where (error as? URLError)?.code == .timedOut {
            errorMessage = "The request timed out. The address may have been saved. Check your addresses before trying again."
            return false
        } catch is CancellationError {
            return false
        } catch NetworkError.transport(let error) where (error as? URLError)?.code == .cancelled {
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
