import SwiftUI

struct CheckoutView: View {
    @State private var viewModel: CheckoutViewModel
    @State private var addressesViewModel: AddressesViewModel
    @State private var addressForm: AddressFormSession?
    @Environment(\.dismiss) private var dismiss

    private let cart: CartResponse
    private let makeAddressForm: (Address?) -> AddressFormViewModel
    private let onPaymentSucceeded: () async -> Void

    private struct AddressFormSession: Identifiable {
        let id = UUID()
        let viewModel: AddressFormViewModel
    }

    init(
        viewModel: CheckoutViewModel,
        addressesViewModel: AddressesViewModel,
        cart: CartResponse,
        makeAddressForm: @escaping (Address?) -> AddressFormViewModel,
        onPaymentSucceeded: @escaping () async -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _addressesViewModel = State(initialValue: addressesViewModel)
        self.cart = cart
        self.makeAddressForm = makeAddressForm
        self.onPaymentSucceeded = onPaymentSucceeded
    }

    private var inputsLocked: Bool {
        viewModel.isLoading || viewModel.createdOrder != nil || viewModel.needsOrderVerification
    }

    var body: some View {
        Form {
            if let payment = viewModel.paymentResponse {
                Section {
                    Label("Payment confirmed", systemImage: "checkmark.circle.fill")
                        .font(AppFonts.headline)
                        .foregroundStyle(.green)
                    Text("Your order has been placed using simulated payment.")
                    LabeledContent("Order", value: payment.orderId)
                    LabeledContent("Payment reference", value: payment.paymentId)
                    amountRow("Total paid", payment.total)
                    orderDetailsLink(payment.orderId)
                    Button("Done") { dismiss() }
                }
            } else if let order = viewModel.verifiedOrder, viewModel.isFinished {
                Section("Order confirmed") {
                    LabeledContent("Status", value: order.status)
                    amountRow("Total", order.total)
                    orderDetailsLink(order.id)
                    Button("Done") { dismiss() }
                }
            } else {
                deliverySection
                itemsSection
                Section("Coupon") {
                    TextField("Coupon code (optional)", text: $viewModel.couponCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .disabled(inputsLocked)
                    Text("Any discount is confirmed when your order is created.")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Section("Order summary") {
                    if let order = viewModel.createdOrder {
                        amountRow("Subtotal", order.subtotal)
                        amountRow("Discount", order.discount)
                        amountRow("Total", order.total)
                        Text("Order: \(order.orderId)")
                            .font(AppFonts.caption)
                            .textSelection(.enabled)
                    } else {
                        amountRow("Cart total", cart.total)
                        Text("Review the final total returned after creating your order, before paying.")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Section("Payment method") {
                    Label("Simulated payment", systemImage: "creditcard")
                    Text("No real money is charged. Card details are not required.")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                if let message = viewModel.errorMessage {
                    Section {
                        Text(message).foregroundStyle(AppColors.error)
                        if viewModel.needsOrderVerification {
                            Text("Check the order status below before attempting payment again. If the order number was not received, review My Orders; do not create another order until the result is confirmed.")
                                .font(AppFonts.caption)
                        }
                    }
                }
                if let order = viewModel.createdOrder {
                    Section { orderDetailsLink(order.orderId) }
                } else if viewModel.needsOrderVerification {
                    Section {
                        NavigationLink("Review My Orders") {
                            OrdersView(viewModel: AppContainer.shared.makeOrdersViewModel())
                        }
                    }
                }
                Section {
                    Button {
                        Task {
                            if viewModel.createdOrder == nil {
                                await viewModel.createOrder()
                            } else {
                                await viewModel.payOrder()
                                if viewModel.isFinished {
                                    await onPaymentSucceeded()
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            Text(viewModel.createdOrder == nil ? "Create Order" : "Confirm Simulated Payment")
                            Spacer()
                        }
                    }
                    .disabled(actionDisabled)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .tint(AppColors.primary)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(viewModel.isLoading)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
                    .disabled(viewModel.isLoading)
            }
        }
        .task {
            if viewModel.createdOrder == nil { await reloadAddresses() }
        }
        .sheet(item: $addressForm, onDismiss: {
            Task { await reloadAddresses() }
        }) { session in
            NavigationStack { AddressFormView(viewModel: session.viewModel) }
        }
    }

    private func orderDetailsLink(_ id: String) -> some View {
        NavigationLink("Order Details & Status") {
            OrderDetailsView(
                viewModel: AppContainer.shared.makeOrderDetailsViewModel(orderID: id),
                onOrderUpdated: { order in
                    viewModel.acceptVerifiedOrder(order)
                    if viewModel.isFinished {
                        Task { await onPaymentSucceeded() }
                    }
                }
            )
        }
        .disabled(viewModel.isLoading)
    }

    private var actionDisabled: Bool {
        viewModel.isLoading || viewModel.needsOrderVerification ||
        (viewModel.createdOrder == nil && (
            addressesViewModel.isLoading || addressesViewModel.errorMessage != nil ||
            !addressesViewModel.addresses.contains { $0.id == viewModel.selectedAddressID }
        ))
    }

    private var deliverySection: some View {
        Section("Delivery details") {
            if addressesViewModel.isLoading {
                ProgressView("Loading addresses…")
            }
            if let message = addressesViewModel.errorMessage {
                Text(message).foregroundStyle(AppColors.error)
                Button("Retry addresses") { Task { await reloadAddresses() } }
                    .disabled(inputsLocked || addressesViewModel.isLoading)
            }
            if addressesViewModel.hasLoaded && addressesViewModel.addresses.isEmpty {
                Text("Add a delivery address with the recipient's name and phone number.")
            }
            ForEach(addressesViewModel.addresses) { address in
                if viewModel.createdOrder == nil || address.id == viewModel.selectedAddressID {
                    Button {
                        viewModel.selectedAddressID = address.id
                    } label: {
                        HStack(alignment: .top) {
                            Image(systemName: address.id == viewModel.selectedAddressID
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(AppColors.primary)
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(address.fullName).font(AppFonts.headline)
                                Text(address.phone)
                                Text(address.addressLine)
                                Text("\(address.city), \(address.country)")
                                if let postalCode = address.postalCode, !postalCode.isEmpty {
                                    Text(postalCode)
                                }
                                if address.isDefault {
                                    Text("Default address").font(AppFonts.caption)
                                }
                            }
                            .foregroundStyle(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(inputsLocked || addressesViewModel.isLoading)
                    .accessibilityAddTraits(address.id == viewModel.selectedAddressID ? .isSelected : [])
                }
            }
            if !inputsLocked {
                Button("Add Address", systemImage: "plus") {
                    addressForm = AddressFormSession(viewModel: makeAddressForm(nil))
                }
                .disabled(addressesViewModel.isLoading)
                if let selected = addressesViewModel.addresses.first(where: { $0.id == viewModel.selectedAddressID }) {
                    Button("Edit Selected Address") {
                        addressForm = AddressFormSession(viewModel: makeAddressForm(selected))
                    }
                    .disabled(addressesViewModel.isLoading)
                }
            }
        }
    }

    private var itemsSection: some View {
        Section("Items at checkout") {
            ForEach(cart.items) { item in
                HStack(spacing: AppSpacing.medium) {
                    NetworkImage(url: item.images.first.flatMap(URL.init(string:)))
                        .frame(width: 52, height: 52)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(item.title).font(AppFonts.bodyMedium)
                        Text("Quantity: \(item.quantity)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    PriceView(price: item.subtotal)
                }
            }
        }
    }

    private func amountRow(_ title: String, _ amount: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            PriceView(price: amount)
        }
    }

    private func reloadAddresses() async {
        await addressesViewModel.fetchAddresses()
        guard addressesViewModel.errorMessage == nil else { return }
        if !addressesViewModel.addresses.contains(where: { $0.id == viewModel.selectedAddressID }) {
            viewModel.selectedAddressID = addressesViewModel.addresses.first(where: \.isDefault)?.id
                ?? addressesViewModel.addresses.first?.id
        }
    }
}
