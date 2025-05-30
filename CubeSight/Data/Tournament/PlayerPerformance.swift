struct TournamentPlayerPerformance {
  static let miniumPercentage: Double = 0.33

  var matchWins: Int = 0
  var matchLosses: Int = 0
  var gameWins: Int = 0
  var gameLosses: Int = 0
  var draws: Int = 0
  //  TODO(bye): add variable

  // TODO: is this only storing the PlayerID?
  var opponents: [TournamentPlayer] = []

  init() {}

  var matchPoints: Int {
    return matchWins * 3 + draws
  }

  var gamePoints: Int {
    return gameWins * 3
  }

  var totalMatches: Int {
    return matchWins + matchLosses + draws
  }

  var totalGames: Int {
    return gameWins + gameLosses
  }

  var matchWinRate: Double {
    let tmp = Double(matchPoints) / Double(totalMatches * 3)
    if tmp.isFinite && tmp > TournamentPlayerPerformance.miniumPercentage {
      return tmp
    } else {
      return TournamentPlayerPerformance.miniumPercentage
    }
  }

  var gameWinRate: Double {
    let tmp = Double(gamePoints) / Double(totalGames * 3)
    if tmp.isFinite && tmp > TournamentPlayerPerformance.miniumPercentage {
      return tmp
    } else {
      return TournamentPlayerPerformance.miniumPercentage
    }
  }

  func matchWinRate(for opponents: [TournamentPlayerPerformance]) -> Double {
    return opponents.reduce(into: 0.0) { $0 += $1.matchWinRate } / Double(opponents.count)
  }

  func gameWinRate(for opponents: [TournamentPlayerPerformance]) -> Double {
    return opponents.reduce(into: 0.0) { $0 += $1.gameWinRate } / Double(opponents.count)
  }

  func matchWinRate(for opponentsMap: [TournamentPlayer: TournamentPlayerPerformance]) -> Double {
    return opponents.reduce(into: 0.0) { $0 += opponentsMap[$1]?.matchWinRate ?? 0.0 }
      / Double(opponentsMap.count)
  }

  func gameWinRate(for opponentsMap: [TournamentPlayer: TournamentPlayerPerformance]) -> Double {
    return opponents.reduce(into: 0.0) { $0 += opponentsMap[$1]?.gameWinRate ?? 0.0 }
      / Double(opponentsMap.count)
  }
}
