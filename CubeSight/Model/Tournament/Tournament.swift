import Foundation
import SwiftData

@Model
class Tournament {
  @Relationship(deleteRule: .cascade, inverse: \TournamentRound.tournament)
  var rounds: [TournamentRound] = []
  @Relationship(inverse: \TournamentPlayer.tournaments) var players:
    [TournamentPlayer] = []

  var createdAt: Date
  var status: TournamentStatus

  func startNextRound(strategy: PairingStrategy = SwissPairingStrategy()) {
    let newMatches = strategy.createPairings(for: players, with: performance)
    let newRound = TournamentRound(
      tournament: self,
      matches: newMatches,
      roundIndex: rounds.count
    )
    rounds.append(newRound)
  }

  init(players: [TournamentPlayer] = []) {
    self.createdAt = Date.now
    self.players = players
    self.status = .ongoing
  }
}

extension Tournament {

  var performance: [TournamentPlayer: TournamentPlayerPerformance] {
    var performance = Dictionary(
      uniqueKeysWithValues: self.players.map {
        ($0, TournamentPlayerPerformance())
      }
    )

    let completeMatches =
      rounds
      .flatMap { $0.matches }
      .filter { $0.isComplete }

    for match in completeMatches {
      var player1Performance = performance[match.player1]
      player1Performance?.gameWins += match.player1Wins
      player1Performance?.gameLosses += match.player2Wins
      player1Performance?.draws += match.draws
      player1Performance?.opponents.append(match.player2)

      var player2Performance = performance[match.player2]
      player2Performance?.gameWins += match.player2Wins
      player2Performance?.gameLosses += match.player1Wins
      player2Performance?.draws += match.draws
      player2Performance?.opponents.append(match.player1)

      // Update match results
      if match.winner != nil {
        if match.player1Wins > match.player2Wins {
          player1Performance?.matchWins += 1
          player2Performance?.matchLosses += 1
        } else {
          player1Performance?.matchLosses += 1
          player2Performance?.matchWins += 1
        }
      }

      performance[match.player1] = player1Performance
      performance[match.player2] = player2Performance
    }

    return performance
  }
}

extension Tournament {
  @MainActor static var previewTournament: Tournament = Tournament(players: [
    TournamentPlayer(name: "Alice"),
    TournamentPlayer(name: "Bob"),
    TournamentPlayer(name: "Carol"),
    TournamentPlayer(name: "David"),
    TournamentPlayer(name: "Eve"),
    TournamentPlayer(name: "Frank"),
  ])

  @MainActor static func makeSampleTournaments(in context: ModelContainer) {
    context.mainContext.insert(previewTournament)
  }
}
