import Foundation

struct Banner: Decodable, Identifiable {
    let id: String
    let title: String?
    let image: String
    let link: String?
}
