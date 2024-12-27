import Foundation
import SwiftData

@Model class DeckCard {
  var card: Card
  var quantity: Int

  init(card: Card, quantity: Int = 1) {
    self.card = card
    self.quantity = quantity
  }
}
