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

extension Cube {
  @MainActor static let sampleCube = Cube(id: UUID().uuidString, shortId: "dimlas4", name: "Vintage Cube")

  @MainActor
  static func makeSampleCube(in context: ModelContainer) {
    context.mainContext.insert(Card.blackLotus)
    sampleCube.mainboard = [Card.blackLotus]
    context.mainContext.insert(sampleCube)
  }
}
