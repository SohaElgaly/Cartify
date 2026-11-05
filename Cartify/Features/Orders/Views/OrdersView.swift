import SwiftUI

struct OrdersView: View {
    @State private var viewModel: OrdersViewModel

    private let includesIncomplete: Bool
    private var visibleOrders: [Order] {
        includesIncomplete ? viewModel.orders : viewModel.orders.filter(\.isConfirmed)
    }

    init(viewModel: OrdersViewModel, includesIncomplete: Bool = false) {
        self.includesIncomplete = includesIncomplete
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

                if viewModel.hasLoaded && visibleOrders.isEmpty {
                    ContentUnavailableView(
                        viewModel.canLoadMore ? "No matching orders on this page" : "No confirmed orders yet",
                        systemImage: "shippingbox",
                        description: Text("Confirmed orders and delivery updates appear here. Pull down to refresh.")
                    )
                }

                ForEach(visibleOrders) { order in
                    NavigationLink {
                        OrderDetailsView(
                            viewModel: AppContainer.shared.makeOrderDetailsViewModel(orderID: order.id),
                            onOrderUpdated: { viewModel.updateOrder($0) }
                        )
                    } label: {
                        orderCard(order)
                    }
                    .buttonStyle(.plain)
                    if order.id != visibleOrders.last?.id { Divider() }
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
        HStack(spacing: 14) {
            NetworkImage(url: order.items.first?.image.flatMap(URL.init(string:)))
                .frame(width: 58, height: 58)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text("Order #\(order.id.suffix(8).uppercased())")
                    .font(AppFonts.bodyMedium)
                Text("\(order.items.reduce(0) { $0 + $1.quantity }) items · \(DisplayDate.string(order.createdAt))")
                    .font(AppFonts.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                OrderStatusBadge(status: order.status)
            }
            Spacer(minLength: 4)
            PriceView(price: order.total)
            Image(systemName: "chevron.right")
                .font(.caption).foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
