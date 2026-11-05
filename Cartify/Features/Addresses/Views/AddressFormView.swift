import SwiftUI

struct AddressFormView: View {
    @State private var viewModel: AddressFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AddressFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Recipient") {
                TextField("Full name", text: $viewModel.fullName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Recipient full name")
                TextField("Phone number", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .accessibilityLabel("Phone number")
            }

            Section("Delivery address") {
                TextField("Country", text: $viewModel.country)
                    .textContentType(.countryName)
                    .accessibilityLabel("Country")
                TextField("City", text: $viewModel.city)
                    .textContentType(.addressCity)
                    .accessibilityLabel("City")
                TextField("Street, building and apartment", text: $viewModel.addressLine, axis: .vertical)
                    .textContentType(.fullStreetAddress)
                    .lineLimit(2...4)
                    .accessibilityLabel("Street, building and apartment")
                TextField("Postal code (optional)", text: $viewModel.postalCode)
                    .textContentType(.postalCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityLabel("Postal code, optional")
            }

            Section {
                Toggle("Use as default address", isOn: $viewModel.isDefault)
            } footer: {
                Text("Your first address becomes the default. Postal code is optional.")
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.error)
                }
            }
        }
        .disabled(viewModel.isSaving)
        .scrollDismissesKeyboard(.interactively)
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .tint(AppColors.primary)
        .navigationTitle(viewModel.isEditing ? "Edit Address" : "Add Address")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(viewModel.isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        if await viewModel.saveAddress() { dismiss() }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView().accessibilityLabel("Saving address")
                    } else {
                        Text("Save").fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
