import SwiftUI

struct AddressesView: View {
    @State private var viewModel: AddressesViewModel
    @State private var formSession: FormSession?
    @State private var deletionTarget: Address?
    @State private var showingDeleteConfirmation = false
    private let makeFormViewModel: (Address?) -> AddressFormViewModel

    // Each presentation gets a fresh form, so an old draft isn't reused.
    private struct FormSession: Identifiable {
        let id = UUID()
        let viewModel: AddressFormViewModel
    }

    init(viewModel: AddressesViewModel,
         makeFormViewModel: @escaping (Address?) -> AddressFormViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.makeFormViewModel = makeFormViewModel
    }

    private var isBusy: Bool {
        viewModel.isLoading || viewModel.deletingAddressID != nil
    }

    var body: some View {
        Group {
            if viewModel.isLoading && !viewModel.hasLoaded {
                LoadingView(message: "Loading your addresses…")
            } else if !viewModel.hasLoaded, let message = viewModel.errorMessage {
                StateView(imageName: "exclamationmark.triangle", imageColor: AppColors.primary,
                          title: "Couldn't load addresses", message: message, buttonTitle: "Try Again") {
                    Task { await viewModel.fetchAddresses() }
                }
            } else if viewModel.hasLoaded {
                addressList
            } else {
                StateView(imageName: "mappin.and.ellipse", imageColor: AppColors.primary,
                          title: "Your addresses", message: "Load your saved delivery addresses.",
                          buttonTitle: "Load addresses") {
                    Task { await viewModel.fetchAddresses() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle("Addresses")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.primary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { openForm() } label: { Label("Add address", systemImage: "plus") }
                    .disabled(isBusy)
            }
        }
        .task { await viewModel.fetchAddresses() }
        .sheet(item: $formSession, onDismiss: {
            // Also refresh after cancelling: a timed-out save may have reached the server.
            Task { await viewModel.fetchAddresses() }
        }) { session in
            NavigationStack { AddressFormView(viewModel: session.viewModel) }
        }
        .confirmationDialog("Delete this address?", isPresented: $showingDeleteConfirmation,
                            titleVisibility: .visible, presenting: deletionTarget) { address in
            Button("Delete address", role: .destructive) {
                Task { await viewModel.deleteAddress(id: address.id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { address in
            Text("\(address.fullName) — \(address.addressLine)")
        }
    }

    private var addressList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                if let message = viewModel.errorMessage ?? viewModel.actionErrorMessage {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(message).font(AppFonts.caption).foregroundStyle(AppColors.error)
                        Button("Refresh addresses") {
                            Task { await viewModel.fetchAddresses() }
                        }
                        .disabled(isBusy)
                    }
                }

                if viewModel.addresses.isEmpty {
                    StateView(imageName: "mappin.and.ellipse", imageColor: AppColors.primary,
                              title: "No saved addresses", message: "Add a delivery address for your next order.",
                              buttonTitle: "Add Address", actionButton: { openForm() })
                        .frame(minHeight: 280)
                        .disabled(isBusy)
                } else {
                    Text("Your delivery locations")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    ForEach(viewModel.addresses) { address in
                        addressCard(address)
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .refreshable { await viewModel.fetchAddresses() }
    }

    private func addressCard(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(address.fullName).font(AppFonts.headline)
            if address.isDefault {
                Label("Default address", systemImage: "checkmark.circle.fill")
                    .font(AppFonts.captionMedium)
                    .foregroundStyle(AppColors.primary)
            }
            Text(address.addressLine).font(AppFonts.body)
            Text("\(address.city), \(address.country)").font(AppFonts.caption)
            if let postalCode = address.postalCode, !postalCode.isEmpty {
                Text("Postal code: \(postalCode)").font(AppFonts.caption)
            }
            Text(address.phone).font(AppFonts.caption).foregroundStyle(AppColors.textSecondary)

            Divider()
            HStack {
                Button { openForm(address) } label: { Label("Edit", systemImage: "pencil") }
                    .accessibilityLabel("Edit address for \(address.fullName), \(address.addressLine)")
                Spacer()
                if viewModel.deletingAddressID == address.id {
                    ProgressView().accessibilityLabel("Deleting address")
                } else {
                    Button(role: .destructive) {
                        deletionTarget = address
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityLabel("Delete address for \(address.fullName), \(address.addressLine)")
                }
            }
            .font(AppFonts.captionMedium)
            .frame(minHeight: 44)
            .disabled(isBusy)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.large).stroke(AppColors.border))
    }

    private func openForm(_ address: Address? = nil) {
        formSession = FormSession(viewModel: makeFormViewModel(address))
    }
}
