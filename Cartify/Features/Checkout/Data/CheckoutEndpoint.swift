import Foundation

enum CheckoutEndpoint: EndPoint {
    case createOrder(CheckoutRequest)
    case payOrder(orderId:String)

    var path: String {
        switch self {
        case .createOrder:
            return  "api/orders/checkout"
        case .payOrder(let orderId):
            return  "api/orders/\(orderId)/pay"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var requiresAuthentication: Bool {
        true
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var body: Data? {
        switch self {
        case .createOrder(let request):
            return try? JSONEncoder().encode(request)
        case .payOrder(orderId: let orderId):
            return nil
        }
    }
}
