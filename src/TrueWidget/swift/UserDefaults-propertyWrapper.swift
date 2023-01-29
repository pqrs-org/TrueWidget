import Foundation
import SwiftUI

@propertyWrapper
struct UserDefault<T> {
  let key: String
  let defaultValue: T

  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    nonmutating set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}

@propertyWrapper
struct UserDefaultJson<T: Codable> {
  let key: String
  let defaultValue: T

  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      if let data = UserDefaults.standard.data(forKey: key) {
        do {
          let decoder = JSONDecoder()
          return try decoder.decode(T.self, from: data)
        } catch {
          print("Failed to decode: (\(error))")
        }
      }

      return defaultValue
    }
    nonmutating set {
      do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(newValue)
        UserDefaults.standard.set(data, forKey: key)
      } catch {
        print("Failed to encode: (\(error))")
      }
    }
  }
}
