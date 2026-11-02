//
//  CheckoutViewModel.swift
//  Cartify
//
//  Created by Soha Elgaly on 19/10/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class CheckoutViewModel {

    // MARK: - User input

    var selectedAddressID: String?
    var couponCode = ""

    // MARK: - Screen state

    private(set) var createdOrder: CheckoutResponse?
    private(set) var paymentResponse: PaymentResponse?

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // Stops another attempt when the previous result is uncertain.
    private(set) var needsOrderVerification = false
    private(set) var verifiedOrder: Order?

    var isFinished: Bool {
        paymentResponse != nil || verifiedOrder.map {
            ["Paid", "Processing", "Shipped", "Delivered", "Cancelled"].contains($0.status)
        } == true
    }

    func acceptVerifiedOrder(_ order: Order) {
        guard order.id == createdOrder?.orderId else { return }
        verifiedOrder = order
        // Continue payment in Order Details, which verifies status before sending.
        needsOrderVerification = true
    }

    // MARK: - Dependencies

    private let repository: CheckoutRepository
    private let ordersRepository: OrdersRepository

    init(repository: CheckoutRepository, ordersRepository: OrdersRepository) {
        self.repository = repository
        self.ordersRepository = ordersRepository
    }

    // MARK: - Create order

    func createOrder() async {
        guard !isLoading,
              !needsOrderVerification,
              createdOrder == nil else {
            return
        }

        errorMessage = nil

        guard let addressID = selectedAddressID,
              !addressID.isEmpty else {
            errorMessage = "Please select a delivery address."
            return
        }

        let trimmedCoupon = couponCode.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let request = CheckoutRequest(
            addressId: addressID,
            couponCode: trimmedCoupon.isEmpty ? nil : trimmedCoupon
        )

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            createdOrder = try await repository.createOrder(
                request: request
            )
        } catch {
            handleError(
                error,
                uncertainMessage:
                    "We couldn't confirm whether your order was created. Check its status before trying again."
            )
        }
    }

    // MARK: - Pay for order

    func payOrder() async {
        guard !isLoading,
              !needsOrderVerification,
              paymentResponse == nil else {
            return
        }

        errorMessage = nil

        guard let order = createdOrder else {
            errorMessage = "Please create your order first."
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let currentOrder = try await ordersRepository.fetchOrder(id: order.orderId)
            guard currentOrder.id == order.orderId else { throw NetworkError.invalidResponse }
            guard currentOrder.status == "Pending" else {
                acceptVerifiedOrder(currentOrder)
                return
            }
            let response = try await repository.payOrder(
                orderId: order.orderId
            )

            guard response.orderId == order.orderId,
                  response.status == "Paid" else {
                needsOrderVerification = true
                errorMessage =
                    "We couldn't confirm payment. Check the order status before trying again."
                return
            }

            paymentResponse = response

        } catch {
            handleError(
                error,
                uncertainMessage:
                    "We couldn't confirm payment. Check the order status before trying again."
            )
        }
    }

    // MARK: - Error handling

    private func handleError(
        _ error: Error,
        uncertainMessage: String
    ) {
        guard let networkError = error as? NetworkError else {
            needsOrderVerification = true
            errorMessage = uncertainMessage
            return
        }

        switch networkError {
        case .apiError(let statusCode, let message, let code):
            if statusCode >= 500 || code == "ORDER_ALREADY_PROCESSED" {
                needsOrderVerification = true
                errorMessage = uncertainMessage
            } else {
                errorMessage = message
            }

        case .serverError(let statusCode):
            if statusCode >= 500 {
                needsOrderVerification = true
                errorMessage = uncertainMessage
            } else {
                errorMessage = networkError.localizedDescription
            }

        case .transport, .decoding, .invalidResponse:
            needsOrderVerification = true
            errorMessage = uncertainMessage

        case .invalidURL,
             .missingAccessToken,
             .missingRefreshToken,
             .authenticationError:
            errorMessage = networkError.localizedDescription
        }
    }
}
