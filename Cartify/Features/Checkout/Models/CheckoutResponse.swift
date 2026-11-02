import Foundation

struct CheckoutResponse: Decodable {
    let orderId: String
    let subtotal: Double
    let discount: Double
    let total: Double
}
