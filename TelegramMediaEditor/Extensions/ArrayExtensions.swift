import Foundation

extension Array: UserDefaultsSavable where Element: Codable {
    func save(_ key: String) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: key)
    }
    
    static func restore(_ key: String) -> Self? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        return try? PropertyListDecoder().decode(Self.self, from: data)
    }
}
