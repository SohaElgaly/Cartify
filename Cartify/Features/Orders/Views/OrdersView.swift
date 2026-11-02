import SwiftUI

struct OrdersView: View {
    @State private var viewModel: OrdersViewModel

    init(viewModel: OrdersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                if viewModel.isLoading && !viewModel.hasLoaded {
                    ProgressView("Loading orders…")
                        .frame(maxWidth: .infinity)
                }

                if let message = viewModel.errorMessage {
                    errorNotice(message) {
                        Task { await viewModel.fetchOrders() }
                    }
                }

                if viewModel.hasLoaded && viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "No orders yet",
                        systemImage: "shippingbox",
                        description: Text("Your orders will appear here after checkout.")
                    )
                }

                ForEach(viewModel.orders) { order in
                    NavigationLink {
                        OrderDetailsView(
                            viewModel: AppContainer.shared.makeOrderDetailsViewModel(orderID: order.id),
                            onOrderUpdated: { viewModel.updateOrder($0) }
                        )
                    } label: {
                        orderCard(order)
                    }
                    .buttonStyle(.plain)
                }

                if let message = viewModel.loadMoreErrorMessage {
                    errorNotice(message) {
                        Task { await viewModel.loadMore() }
                    }
                } else if viewModel.canLoadMore {
                    Button {
                        Task { await viewModel.loadMore() }
                    } label: {
                        HStack {
                            if viewModel.isLoadingMore { ProgressView() }
                            Text(viewModel.isLoadingMore ? "Loading…" : "Load More")
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isLoading || viewModel.isLoadingMore)
                }

                if !viewModel.hasLoaded && !viewModel.isLoading && viewModel.errorMessage == nil {
                    Button("Load Orders") {
                        Task { await viewModel.fetchOrders() }
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColors.background)
        .tint(AppColors.primary)
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !viewModel.hasLoaded { await viewModel.fetchOrders() }
        }
        .refreshable { await viewModel.fetchOrders() }
    }

    private func errorNotice(_ message: String, retry: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(message).foregroundStyle(AppColors.error)
            Button("Try Again", action: retry)
                .disabled(viewModel.isLoading || viewModel.isLoadingMore)
        }
        .font(AppFonts.caption)
    }

    private func orderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack {
                Label(order.status, systemImage: "shippingbox")
                    .font(AppFonts.headline)
                Spacer()
                PriceView(price: order.total)
            }
            Text("Order #\(order.id)")
                .font(AppFonts.caption)
                .textSelection(.enabled)
            Text(formattedDate(order.createdAt))
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
            Divider()
            Text(order.items.map { "\($0.title) × \($0.quantity)" }.joined(separator: "\n"))
                .font(AppFonts.bodyMedium)
            Text("Deliver to \(order.shippingAddress.fullName) · \(order.shippingAddress.city)")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }

    private func formattedDate(_ value: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: value)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: value)
        }
        return date?.formatted(date: .abbreviated, time: .shortened) ?? value
    }
}
