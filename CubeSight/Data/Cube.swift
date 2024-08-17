import Foundation
import SwiftData

@Model class Cube {
  @Attribute(.unique) var id: String
  @Attribute(.unique) var shortId: String
  var name: String
  @Attribute(.externalStorage) var image: Data?

  var mainboard: [Card] = []

  @Relationship(deleteRule: .cascade, inverse: \Deck.cube) var decks: [Deck] = []

  init(id: String, shortId: String, name: String) {
    self.id = id
    self.shortId = shortId
    self.name = name
  }
}

extension Cube {
  static let sampleCube = Cube(id: UUID().uuidString, shortId: "dimlas4", name: "Vintage Cube")

  static func insertSampleData(modelContext: ModelContext) {
    modelContext.insert(Card.blackLotus)

    sampleCube.mainboard = [Card.blackLotus]
    modelContext.insert(sampleCube)

    modelContext.insert(Deck.sampleDeck)
    Deck.sampleDeck.cards = [Card.blackLotus]
  }
}
