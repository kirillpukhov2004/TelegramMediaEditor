import Foundation

protocol UserDefaultsSavable: Codable {
    func save(_ key: String)
    static func restore(_ key: String) -> Self?
}
