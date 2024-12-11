//
//  Tournament.swift
//  CubeSight
//
//  Created by Noe Thalheim on 22.09.2024.
//

import SwiftData

@Model
class Tournament {
  @Relationship(deleteRule: .cascade) var rounds: [Round]
  @Relationship var players: [Player]
  var currentRoundIndex: Int

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

  private func calculatePerformance() -> [Player: PlayerPerformance] {
    let matches: [Match] = rounds.flatMap { $0.matches }.filter { $0.isComplete() }
    var performance = Dictionary(uniqueKeysWithValues: players.map { ($0, PlayerPerformance()) })
    matches.forEach { $0.process(into: &performance) }
    return performance
  }

  func invalidatePerformanceCache() {
    _performance = nil
  }

  init(players: [Player]) {
    self.rounds = []
    self.currentRoundIndex = 0
    self.players = players
  }
}

@Model
class Round {
  var matches: [Match]
  // TODO: make this a round state enum (running, done)
  var isCompleted: Bool

  init(matches: [Match]) {
    self.matches = matches
    self.isCompleted = false
  }
}


