import Foundation

import Foundation

extension Dictionary: UserDefaultsSavable where Key: Codable, Value: Codable {
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
