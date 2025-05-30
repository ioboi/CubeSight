import Foundation
import SwiftData

@Model
class Tournament {
  @Relationship(deleteRule: .cascade) var rounds: [TournamentRound] = []
  // TODO: to one?
  @Relationship(inverse: \TournamentPlayer.tournaments) var players: [TournamentPlayer] = []
  var createdAt: Date

  @Transient
  private var _performance: [TournamentPlayer: PlayerPerformance]?

  var performance: [TournamentPlayer: PlayerPerformance] {
    //    if let cached = _performance {
    //      return cached
    //    }
    let calculated = calculatePerformance()
    _performance = calculated
    return calculated
  }

  func getPerformance(for player: TournamentPlayer) -> PlayerPerformance? {
    performance[player]
  }

  private func calculatePerformance() -> [TournamentPlayer: PlayerPerformance] {
    let matches: [TournamentMatch] = rounds.flatMap { $0.matches }.filter {
      $0.isComplete()
    }
    var performance = Dictionary(
      uniqueKeysWithValues: players.map { ($0, PlayerPerformance()) }
    )
    matches.forEach { $0.process(into: &performance) }
    return performance
  }

  func invalidatePerformanceCache() {
    _performance = nil
  }

  func startNextRound(strategy: PairingStrategy) {
    //  TODO(performance): only add current round peformance, i.e. update tournament.performance instead
    invalidatePerformanceCache()
    //  TODO: add guard that previous round is complete

    let newMatches = strategy.createPairings(for: players, with: performance)
    let newRound = TournamentRound(
      matches: newMatches,
      roundIndex: rounds.count
    )

    rounds.append(newRound)
  }

  init(players: [TournamentPlayer] = []) {
    self.createdAt = Date.now
    self.players = players
  }
}
