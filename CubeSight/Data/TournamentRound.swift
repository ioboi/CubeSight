import SwiftData

@Model
class TournamentRound {
  var matches: [TournamentMatch]
  // TODO: make this a round state enum (running, done)
  var isCompleted: Bool
  var roundIndex: Int

  init(matches: [TournamentMatch], roundIndex: Int) {
    self.matches = matches
    self.isCompleted = false
    self.roundIndex = roundIndex
  }
}
