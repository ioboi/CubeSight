protocol PairingStrategy {
  func createPairings(
    for players: [TournamentPlayer],
    with performance: [TournamentPlayer: TournamentPlayerPerformance]
  )
    -> [TournamentMatch]
}

struct SwissPairingStrategy: PairingStrategy {
  func createPairings(
    for players: [TournamentPlayer],
    with performance: [TournamentPlayer: TournamentPlayerPerformance]
  ) -> [TournamentMatch] {

    func hasPlayed(_ player1: TournamentPlayer, _ player2: TournamentPlayer)
      -> Bool
    {
      return performance[player1]?.opponents.contains(player2) ?? false
    }

    guard players.allSatisfy({ performance[$0] != nil }) else {
      fatalError("all player need to have performance")
    }

    let unpairedPlayers = players.sorted {
      performance[$0]!.matchPoints > performance[$1]!.matchPoints
    }

    var matches: [TournamentMatch] = []
    var remainingPlayers = unpairedPlayers

    while remainingPlayers.count >= 2 {
      let player1 = remainingPlayers.removeFirst()

      if let player2Index = remainingPlayers.firstIndex(where: {
        !hasPlayed(player1, $0)
      }) {
        let player2 = remainingPlayers.remove(at: player2Index)
        matches.append(TournamentMatch(player1: player1, player2: player2))
      } else {
        let player2 = remainingPlayers.removeFirst()
        matches.append(TournamentMatch(player1: player1, player2: player2))
      }
    }
    return matches
  }
}
