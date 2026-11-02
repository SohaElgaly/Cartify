import SwiftUI

struct OrderDetailsView: View {
    @State private var viewModel: OrderDetailsViewModel
    @State private var confirmingPayment = false
    private let onOrderUpdated: (Order) -> Void

    init(viewModel: OrderDetailsViewModel, onOrderUpdated: @escaping (Order) -> Void = { _ in }) {
        _viewModel = State(initialValue: viewModel)
        self.onOrderUpdated = onOrderUpdated
    }

    var body: some View {
        Form {
            if viewModel.isLoading { ProgressView("Checking order…") }
            if let message = viewModel.errorMessage {
                Section {
                    Text(message).foregroundStyle(AppColors.error)
                    Button("Check Order Status") { Task { await refresh() } }
                        .disabled(viewModel.isLoading || viewModel.isPaying)
                }
            }
            if let order = viewModel.order {
                Section("Order") {
                    LabeledContent("Status", value: order.status)
                    Text(order.id).textSelection(.enabled)
                    Text(order.createdAt).font(AppFonts.caption)
                }
                Section("Items") {
                    ForEach(Array(order.items.enumerated()), id: \.offset) { _, item in
                        HStack {
                            NetworkImage(url: URL(string: item.image))
                                .frame(width: 50, height: 50).clipped()
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text("Quantity: \(item.quantity)").font(AppFonts.caption)
                            }
                            Spacer()
                            PriceView(price: item.subtotal)
                        }
                    }
                }
                Section("Delivery address") {
                    Text(order.shippingAddress.fullName)
                    Text(order.shippingAddress.phone)
                    Text(order.shippingAddress.addressLine)
                    Text("\(order.shippingAddress.city), \(order.shippingAddress.country)")
                    if let postal = order.shippingAddress.postalCode { Text(postal) }
                }
                Section("Summary") {
                    amount("Subtotal", order.subtotal)
                    amount("Discount", order.discount)
                    if let coupon = order.coupon { LabeledContent("Coupon", value: coupon.code) }
                    amount("Total", order.total)
                }
                Section("Payment") {
                    if let paymentID = order.paymentId {
                        Text(paymentID).textSelection(.enabled)
                    }
                    if let paidAt = order.paidAt { Text(paidAt).font(AppFonts.caption) }
                    if order.status == "Pending" {
                        Text("Simulated payment. No real money will be charged.")
                            .font(AppFonts.caption)
                        Button("Pay for This Order") { confirmingPayment = true }
                            .disabled(!viewModel.canPay)
                    }
                    if viewModel.isPaying { ProgressView("Confirming payment…") }
                    if viewModel.requiresVerification {
                        Text("Refresh the order status before attempting payment.")
                            .font(AppFonts.caption)
                    }
                }
            } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                Button("Load Order") { Task { await refresh() } }
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.primary)
        .task { await refresh() }
        .refreshable { await refresh() }
        .confirmationDialog("Confirm simulated payment?", isPresented: $confirmingPayment, titleVisibility: .visible) {
            Button("Confirm Payment") {
                Task {
                    await viewModel.pay()
                    if let order = viewModel.order { onOrderUpdated(order) }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func refresh() async {
        await viewModel.refresh()
        if let order = viewModel.order, !viewModel.requiresVerification { onOrderUpdated(order) }
    }

    private func amount(_ title: String, _ value: Double) -> some View {
        HStack { Text(title); Spacer(); PriceView(price: value) }
    }
}
