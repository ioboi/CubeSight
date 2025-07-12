import Foundation
import SwiftData

@Model
class TournamentPlayer {
  @Relationship(inverse: \Tournament.players) var tournament: Tournament?
  var player: Player
  var seating: Int?
  var draftedDeck: CubeDeck?

  var name: String { player.name }

  init(player: Player) {
    self.player = player
  }
}
