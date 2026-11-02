//
//  OrdersViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 20/10/2026.
//

import Foundation
import Observation

@Observable
@MainActor

final class OrdersViewModel {
    private let repository: OrdersRepository
    
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var orders: [Order] = []
    private(set) var hasLoaded = false
    private(set) var isLoadingMore = false
    private(set) var loadMoreErrorMessage: String?
    private(set) var pagination: Pagination?
    private let pageSize = 10
    init(repository: OrdersRepository) {
        self.repository = repository
    }
    
    var canLoadMore: Bool {
            guard let pagination else {
                return false
            }

            return pagination.page < pagination.totalPages
        }
    func fetchOrders() async {
        guard !isLoading, !isLoadingMore else {
            return
        }

        errorMessage = nil
        loadMoreErrorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await repository.fetchOrders(
                page: 1,
                limit: pageSize
            )

            orders = response.orders
            pagination = response.pagination
            hasLoaded = true

        } catch is CancellationError {
            return

        } catch NetworkError.transport(let error)
            where (error as? URLError)?.code == .cancelled {
            return

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func loadMore() async {
        guard !isLoading, !isLoadingMore, canLoadMore,
              let pagination else { return }

        loadMoreErrorMessage = nil
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let response = try await repository.fetchOrders(
                page: pagination.page + 1,
                limit: pageSize
            )

            // Page boundaries can shift when new orders are created.
            // Update an existing order instead of displaying its ID twice.
            for order in response.orders {
                if let index = orders.firstIndex(where: { $0.id == order.id }) {
                    orders[index] = order
                } else {
                    orders.append(order)
                }
            }
            self.pagination = response.pagination
        } catch is CancellationError {
            return
        } catch NetworkError.transport(let error)
            where (error as? URLError)?.code == .cancelled {
            return
        } catch {
            loadMoreErrorMessage = error.localizedDescription
        }
    }
    func updateOrder(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
        }
    }
}
