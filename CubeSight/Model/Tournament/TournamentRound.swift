import SwiftData

@Model
class TournamentRound {
  var tournament: Tournament
  var matches: [TournamentMatch]
  var roundIndex: Int

  init(tournament: Tournament, matches: [TournamentMatch], roundIndex: Int) {
    self.tournament = tournament
    self.matches = matches
    self.roundIndex = roundIndex
  }
}
