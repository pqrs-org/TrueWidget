import Foundation

@propertyWrapper
struct CodableAppStorage<T: Codable> {
  private let key: String
  private let defaultValue: T

  init(wrappedValue: T, _ key: String) {
    self.key = key
    self.defaultValue = wrappedValue
  }

  var wrappedValue: T {
    get {
      if let data = UserDefaults.standard.data(forKey: key),
        let decoded = try? JSONDecoder().decode(T.self, from: data)
      {
        return decoded
      }
      return defaultValue
    }
    set {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(data, forKey: key)
      }
    }
  }
}
