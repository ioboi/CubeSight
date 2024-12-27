import Foundation
import SwiftData

@Model class Deck {
  @Attribute(.unique) var id: UUID
  @Attribute var createdAt: Date
  @Attribute var name: String
  
  var cube: Cube
  var cards: [Card] = []
  
  init(cube: Cube, createdAt: Date = Date(), name: String = "") {
    self.id = UUID()
    self.createdAt = createdAt
    self.name = name
    self.cube = cube
  }
}

extension Deck {
  static var sampleDeck = Deck(cube: Cube.sampleCube)
}
