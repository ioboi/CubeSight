import Foundation
import SwiftData

@Model
class Tournament {
  @Relationship(deleteRule: .cascade) var rounds: [Round] = []
  // TODO: to one?
  @Relationship(inverse: \Player.tournaments) var players: [Player] = []
  var createdAt: Date

  @Transient
  private var _performance: [Player: PlayerPerformance]?

  var performance: [Player: PlayerPerformance] {
    if let cached = _performance {
      return cached
    }
    let calculated = calculatePerformance()
    _performance = calculated
    return calculated
  }

  func getPerformance(for player: Player) -> PlayerPerformance? {
    performance[player]
  }

  private func calculatePerformance() -> [Player: PlayerPerformance] {
    let matches: [Match] = rounds.flatMap { $0.matches }.filter { $0.isComplete() }
    var performance = Dictionary(uniqueKeysWithValues: players.map { ($0, PlayerPerformance()) })
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
    let newRound = Round(matches: newMatches, roundIndex: rounds.count)

    rounds.append(newRound)
  }

  init() {
    self.createdAt = Date.now
  }
}

@Model
class Round {
  var matches: [Match]
  // TODO: make this a round state enum (running, done)
  var isCompleted: Bool
  var roundIndex: Int

  init(matches: [Match], roundIndex: Int) {
    self.matches = matches
    self.isCompleted = false
    self.roundIndex = roundIndex
  }
}
