import SwiftUI

struct OrderDetailsView: View {
    @State private var viewModel: OrderDetailsViewModel
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
                        .disabled(viewModel.isLoading)
                }
            }
            if let order = viewModel.order {
                Section("Order") {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Order #\(order.id.suffix(8).uppercased())").font(AppFonts.headline)
                            Text(DisplayDate.string(order.createdAt))
                                .font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        OrderStatusBadge(status: order.status)
                    }
                    .padding(.vertical, 8)
                }
                Section("Delivery progress") {
                    if let current = order.deliveryStep {
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(Array(["Confirmed", "Preparing", "Shipped", "Delivered"].enumerated()), id: \.offset) { index, title in
                                HStack(spacing: 12) {
                                    Image(systemName: index < current ? "checkmark.circle.fill" : (index == current ? "largecircle.fill.circle" : "circle"))
                                        .foregroundStyle(index <= current ? AppColors.primary : AppColors.textSecondary)
                                    Text(title).font(index == current ? AppFonts.headline : AppFonts.body)
                                    Spacer()
                                    if index == current { Text("Current").font(AppFonts.footnote).foregroundStyle(AppColors.textSecondary) }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text(Order.deliveryLabel(for: order.status))
                    }
                }
                Section("Items") {
                    ForEach(Array(order.items.enumerated()), id: \.offset) { _, item in
                        HStack {
                            NetworkImage(url: item.image.flatMap(URL.init(string:)))
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(order.shippingAddress.fullName).font(AppFonts.headline)
                        Text(order.shippingAddress.phone)
                        Text(order.shippingAddress.addressLine)
                        Text("\(order.shippingAddress.city), \(order.shippingAddress.country)")
                        if let postal = order.shippingAddress.postalCode, !postal.isEmpty {
                            Text(postal)
                        }
                    }
                    .font(AppFonts.body)
                    .padding(.vertical, 8)
                }
                Section("Bill summary") {
                    amount("Subtotal", order.subtotal)
                    amount("Discount", order.discount)
                    if let coupon = order.coupon { LabeledContent("Coupon", value: coupon.code) }
                    amount("Total", order.total)
                }

            } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                Button("Load Order") { Task { await refresh() } }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.primary)
        .task { await refresh() }
        .refreshable { await refresh() }
    }

    private func refresh() async {
        await viewModel.refresh()
        if let order = viewModel.order, !viewModel.requiresVerification { onOrderUpdated(order) }
    }

    private func amount(_ title: String, _ value: Double) -> some View {
        HStack { Text(title); Spacer(); PriceView(price: value) }
    }
}
