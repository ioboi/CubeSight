import Foundation
import SwiftData

@Model class Player {
  #Unique([\Player.name])

  @Relationship(deleteRule: .cascade, inverse: \TournamentPlayer.player) var tournaments:
    [TournamentPlayer] = []

  var id: UUID
  var name: String

  init(name: String) {
    self.id = UUID()
    self.name = name
  }
}
