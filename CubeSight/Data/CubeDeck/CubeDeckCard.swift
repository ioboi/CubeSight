import Foundation
import SwiftData

@Model class CubeDeckCard {
  @Relationship(deleteRule: .cascade, inverse: \CubeDeck.cards) var deck:
    CubeDeck?

  var card: Card
  var quantity: Int

  init(deck: CubeDeck, card: Card, quantity: Int = 1) {
    self.deck = deck
    self.card = card
    self.quantity = quantity
  }
}
