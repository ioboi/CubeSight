import Numerics
import SwiftData
import Testing

@testable import CubeSight

@MainActor
struct SwissPairingTests {
  let context: ModelContext
  let strategy: PairingStrategy = SwissPairingStrategy()

  init() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: TournamentPlayer.self, Tournament.self, TournamentRound.self, TournamentMatch.self, configurations: config)
    context = container.mainContext
  }

  @Test("Test looser and winner pairing one round")
  func testPairingOneRound() async throws {
    let winnerNames = ["Alice", "Bob", "Charlie", "David"]
    let looserNames = ["Eve", "Frank", "Grace", "Henry"]
    let playerNames = winnerNames + looserNames
    let players = playerNames.map { TournamentPlayer(name: $0) }

    let tournament = Tournament(players: players)
    tournament.startNextRound(strategy: strategy)

    guard let matches = tournament.rounds.last?.matches else {
      Issue.record("No matches found")
      return
    }

    for match in matches {
      if winnerNames.contains(match.player1.name) {
        match.complete(player1Wins: 2, player2Wins: 0, draws: 0)
      } else {
        match.complete(player1Wins: 0, player2Wins: 2, draws: 0)
      }
    }

    //    Check pairings in next round
    tournament.startNextRound(strategy: strategy)
    guard let matches = tournament.rounds.last?.matches else {
      Issue.record("No matches found")
      return
    }
    for match in matches {
      #expect(
        winnerNames.contains(match.player1.name) && winnerNames.contains(match.player2.name)
          || looserNames.contains(match.player1.name) && looserNames.contains(match.player2.name)
      )
    }
  }

  @Test("Test pairing across multiple rounds")
  func testPairingMultipleRounds() async throws {

    // Initial players - we'll track their expected records
    let playerNames = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Henry"]
    let players = playerNames.map { TournamentPlayer(name: $0) }
    let tournament = Tournament(players: players)
    tournament.startNextRound(strategy: strategy)

    // Round 1: Alice, Bob, Charlie, David win
    guard let round = tournament.rounds.last else {
      Issue.record("Tournament should have first round")
      return
    }

    let winnersRoundOne = Set(round.matches.map { $0.player1.name })
    let losersRoundOne = Set(round.matches.map { $0.player2.name })
    for match in round.matches {
      // First 4 players win their matches
      let player1ShouldWin = winnersRoundOne.contains(match.player1.name)
      match.complete(
        player1Wins: player1ShouldWin ? 2 : 0,
        player2Wins: player1ShouldWin ? 0 : 2,
        draws: 0
      )
    }
    tournament.startNextRound(strategy: strategy)

    // Round 2: Check winners play winners, losers play losers
    guard let round = tournament.rounds.last else {
      Issue.record("Tournament should have first round")
      return
    }
    for match in round.matches {
      let bothWinners = [match.player1, match.player2].allSatisfy {
        winnersRoundOne.contains($0.name)
      }
      let bothLosers = [match.player1, match.player2].allSatisfy {
        losersRoundOne.contains($0.name)
      }
      #expect(bothWinners || bothLosers, "Round 2 should pair players based on Round 1 records")
    }

    // Round 2: Alice and Bob win their matches, Eve and Frank win theirs
    let winnersRoundTwo = Set(round.matches.map { $0.player1.name })
    let losersRoundTwo = Set(round.matches.map { $0.player2.name })
    for match in round.matches {
      let player1ShouldWin = winnersRoundTwo.contains(match.player1.name)
      match.complete(
        player1Wins: player1ShouldWin ? 2 : 0,
        player2Wins: player1ShouldWin ? 0 : 2,
        draws: 0
      )
    }

    let bothWon = winnersRoundOne.intersection(winnersRoundTwo)
    let bothLost = losersRoundOne.intersection(losersRoundTwo)
    let oneWonOneLost = Set(playerNames).subtracting(bothWon.union(bothLost))

    tournament.startNextRound(strategy: strategy)
    guard let round = tournament.rounds.last else {
      Issue.record("Tournament should have next round")
      return
    }
    for match in round.matches {
      let both2_0 = [match.player1, match.player2].allSatisfy { bothWon.contains($0.name) }
      let both1_1 = [match.player1, match.player2].allSatisfy { oneWonOneLost.contains($0.name) }
      let both0_2 = [match.player1, match.player2].allSatisfy { bothLost.contains($0.name) }

      #expect(both2_0 || both1_1 || both0_2, "Round 3 should pair players based on overall records")
    }
  }
}
