import Foundation

struct CheckoutRequest: Encodable {
    let addressId: String
    let couponCode: String?
}
