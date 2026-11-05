import SwiftUI

struct CheckoutView: View {
    @State private var viewModel: CheckoutViewModel
    @State private var addressesViewModel: AddressesViewModel
    @State private var addressForm: AddressFormSession?
    @State private var choosingAddress = false
    @State private var validationMessage: String?
    @Environment(\.dismiss) private var dismiss

    private let cart: CartResponse
    private let makeAddressForm: (Address?) -> AddressFormViewModel
    private let onPaymentSucceeded: () async -> Void
    private let onContinueShopping: () -> Void

    private struct AddressFormSession: Identifiable {
        let id = UUID()
        let viewModel: AddressFormViewModel
    }

    init(viewModel: CheckoutViewModel, addressesViewModel: AddressesViewModel,
         cart: CartResponse, makeAddressForm: @escaping (Address?) -> AddressFormViewModel,
         onPaymentSucceeded: @escaping () async -> Void,
         onContinueShopping: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        _addressesViewModel = State(initialValue: addressesViewModel)
        self.cart = cart
        self.makeAddressForm = makeAddressForm
        self.onPaymentSucceeded = onPaymentSucceeded
        self.onContinueShopping = onContinueShopping
    }

    private var inputsLocked: Bool {
        viewModel.isBusy || viewModel.createdOrder != nil || viewModel.needsOrderVerification
    }
    private var selectedAddress: Address? {
        addressesViewModel.addresses.first { $0.id == viewModel.selectedAddressID }
    }
    private var total: Double {
        viewModel.paymentResponse?.total ?? viewModel.verifiedOrder?.total ?? viewModel.createdOrder?.total ?? cart.total
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if viewModel.isFinished {
                    completion
                } else {
                    delivery
                    Divider()
                    payment
                    Divider()
                    summary
                }
            }
            .padding(24)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .foregroundStyle(AppColors.textPrimary)
        .safeAreaInset(edge: .bottom) { footer }
        .tint(AppColors.primary)
        .navigationTitle(viewModel.isFinished ? "Your order" : "Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(viewModel.isBusy)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: { Image(systemName: "xmark") }
                    .accessibilityLabel("Close checkout")
                    .disabled(viewModel.isBusy)
            }
        }
        .task { if viewModel.createdOrder == nil { await reloadAddresses() } }
        .onChange(of: viewModel.selectedAddressID) { _, _ in validationMessage = nil }
        .sheet(item: $addressForm, onDismiss: { Task { await reloadAddresses() } }) { session in
            NavigationStack { AddressFormView(viewModel: session.viewModel) }
        }
    }

    private var delivery: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Delivery address", systemImage: "mappin.and.ellipse").font(AppFonts.headline)
                Spacer()
                if selectedAddress != nil && !inputsLocked {
                    Button("Change") { choosingAddress.toggle() }.font(AppFonts.captionMedium)
                }
            }
            if addressesViewModel.isLoading {
                ProgressView("Loading addresses…")
            } else if addressesViewModel.errorMessage != nil {
                Text("We couldn't load your addresses.").foregroundStyle(AppColors.textSecondary)
                Button("Try again") { Task { await reloadAddresses() } }
            } else if let address = selectedAddress {
                VStack(alignment: .leading, spacing: 6) {
                    Text(address.fullName).font(AppFonts.bodyMedium)
                    Text(address.phone)
                    Text("\(address.addressLine), \(address.city), \(address.country)")
                }
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
            } else {
                Button {
                    addressForm = AddressFormSession(viewModel: makeAddressForm(nil))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add delivery address")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .padding(18)
                    .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(inputsLocked)
            }
            if choosingAddress && !inputsLocked {
                ForEach(addressesViewModel.addresses) { address in
                    Button {
                        viewModel.selectedAddressID = address.id
                        choosingAddress = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(address.fullName)
                                Text(address.addressLine).font(AppFonts.caption)
                            }
                            Spacer()
                            Image(systemName: address.id == viewModel.selectedAddressID ? "checkmark.circle.fill" : "circle")
                        }
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                HStack(spacing: 24) {
                    Button("New address") { addressForm = AddressFormSession(viewModel: makeAddressForm(nil)) }
                    if let selectedAddress {
                        Button("Edit selected") { addressForm = AddressFormSession(viewModel: makeAddressForm(selectedAddress)) }
                    }
                }
                .font(AppFonts.captionMedium)
                .frame(minHeight: 44)
            }
        }
    }

    private var payment: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment method").font(AppFonts.headline)
            ForEach(DemoPaymentMethod.allCases) { method in
                Button { viewModel.demoPaymentMethod = method } label: {
                    HStack(spacing: 12) {
                        Image(systemName: method.symbol).frame(width: 24)
                        Text(method.title).font(AppFonts.bodyMedium)
                        Spacer()
                        Image(systemName: viewModel.demoPaymentMethod == method ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(AppColors.primary)
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 56)
                    .background(viewModel.demoPaymentMethod == method ? AppColors.primaryLight : AppColors.cardBackground,
                                in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(inputsLocked)
                .accessibilityAddTraits(viewModel.demoPaymentMethod == method ? .isSelected : [])
            }
            Text("Simulated checkout. No money is charged or delivery arranged.")
                .font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 18) {
            DisclosureGroup("Your bag · \(cart.items.reduce(0) { $0 + $1.quantity }) items") {
                ForEach(cart.items) { item in
                    HStack(spacing: 12) {
                        Color.white.frame(width: 56, height: 64)
                            .overlay {
                                NetworkImage(url: item.images.first.flatMap(URL.init(string:)), contentMode: .fit).padding(5)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(AppFonts.captionMedium)
                            Text("Qty \(item.quantity)").font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        PriceView(price: item.subtotal)
                    }
                    .padding(.vertical, 8)
                }
            }
            DisclosureGroup("Have a coupon?") {
                TextField("Enter coupon code", text: $viewModel.couponCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .cartifyInput()
                    .disabled(inputsLocked)
                    .padding(.top, 10)
                Text("Valid discounts are applied to your final total.")
                    .font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
            }
            if let order = viewModel.createdOrder, order.discount > 0 {
                amountRow("Subtotal", order.subtotal)
                amountRow("Discount", order.discount)
            }
        }
    }

    private var completion: some View {
        VStack(spacing: 22) {
            Image(systemName: viewModel.verifiedOrder?.status == "Cancelled" ? "xmark.circle" : "checkmark.circle.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.primary)
                .padding(.top, 40)
            Text(viewModel.verifiedOrder?.status == "Cancelled" ? "Order cancelled" : "You're all set!")
                .font(AppFonts.largeTitle)
            Text("You can follow your order from your profile.")
                .font(AppFonts.body).foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            if let id = viewModel.paymentResponse?.orderId ?? viewModel.verifiedOrder?.id {
                VStack(spacing: 16) {
                    Text("Order #\(id.suffix(8).uppercased())").font(AppFonts.captionMedium)
                    amountRow("Total", total)
                    NavigationLink("View order details") {
                        OrderDetailsView(viewModel: AppContainer.shared.makeOrderDetailsViewModel(orderID: id))
                    }
                    .font(AppFonts.captionMedium)
                    .frame(minHeight: 44)
                }
                .padding(24)
                .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
            }
            Text("Simulated checkout — no money was charged.")
                .font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if viewModel.isFinished {
                PrimaryButton(title: "Continue shopping", action: onContinueShopping)
            } else {
                if let message = validationMessage ?? viewModel.errorMessage {
                    Text(message).font(AppFonts.footnote).foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                amountRow("Total", total)
                if viewModel.needsOrderVerification && viewModel.createdOrder == nil {
                    NavigationLink("Review orders before trying again") {
                        OrdersView(viewModel: AppContainer.shared.makeOrdersViewModel(), includesIncomplete: true)
                    }
                    .frame(minHeight: 44)
                } else {
                    PrimaryButton(title: viewModel.needsOrderVerification ? "Check order status" : "Confirm order",
                                  isLoading: viewModel.isBusy, isEnabled: !viewModel.isBusy) {
                        Task { await submit() }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(AppColors.background)
    }

    private func submit() async {
        validationMessage = nil
        if viewModel.needsOrderVerification {
            await viewModel.verifyPaymentStatus()
        } else {
            if viewModel.createdOrder == nil {
                guard !addressesViewModel.isLoading else {
                    validationMessage = "Please wait while we load your addresses."
                    return
                }
                guard addressesViewModel.errorMessage == nil else {
                    validationMessage = "Reload your addresses before confirming your order."
                    return
                }
                guard selectedAddress != nil else {
                    validationMessage = "Add an address to complete your order checkout."
                    return
                }
            }
            await viewModel.confirmPayment()
        }
        if viewModel.isFinished { await onPaymentSucceeded() }
    }

    private func amountRow(_ title: String, _ amount: Double) -> some View {
        HStack {
            Text(title).font(AppFonts.headline)
            Spacer()
            PriceView(price: amount)
        }
    }

    private func reloadAddresses() async {
        await addressesViewModel.fetchAddresses()
        guard addressesViewModel.errorMessage == nil else { return }
        if selectedAddress == nil {
            viewModel.selectedAddressID = addressesViewModel.addresses.first(where: \.isDefault)?.id
                ?? addressesViewModel.addresses.first?.id
        }
    }
}
