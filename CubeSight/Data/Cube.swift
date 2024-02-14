import Foundation
import SwiftData

@Model class Cube {
  @Attribute(.unique) var id: String
  @Attribute(.unique) var shortId: String
  var name: String
  @Attribute(.externalStorage) var image: Data?

  var mainboard: [Card] = []

  init(id: String, shortId: String, name: String) {
    self.id = id
    self.shortId = shortId
    self.name = name
  }
}
