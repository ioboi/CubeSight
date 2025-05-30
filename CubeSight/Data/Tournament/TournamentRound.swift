import SwiftData

@Model
class TournamentRound {
  var tournament: Tournament
  var matches: [TournamentMatch]
  // TODO: make this a round state enum (running, done)
  var isCompleted: Bool
  var roundIndex: Int

  init(tournament: Tournament, matches: [TournamentMatch], roundIndex: Int) {
    self.tournament = tournament
    self.matches = matches
    self.isCompleted = false
    self.roundIndex = roundIndex
  }
}
