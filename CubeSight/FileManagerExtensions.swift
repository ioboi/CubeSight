import Foundation

extension FileManager {
  var documentDirectory: URL? {
    return self.urls(for: .documentDirectory, in: .userDomainMask).first
  }
}
