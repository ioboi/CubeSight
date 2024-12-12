//
//  PairingTests.swift
//  CubeSightTests
//
//  Created by Noe on 11.12.2024.
//

import Numerics
import SwiftData
import Testing

@testable import CubeSight

@MainActor
struct PairingTests {

  @Test("Test looser and winner pairing one round")
  func testPairingOneRound() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)

    let winnerNames = ["Alice", "Bob", "Charlie", "David"]
    let looserNames = ["Eve", "Frank", "Grace", "Henry"]
    let playerNames = winnerNames + looserNames
    let players = playerNames.map { Player(name: $0) }
    players.forEach { modelContext.insert($0) }

    viewModel.startTournament(players: players)

    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }

    var round = viewModel.currentRound()
    for (i, match) in round.matches.enumerated() {
      if winnerNames.contains(match.player1.name) {
        viewModel.completeMatch(
          roundIndex: 0, matchIndex: i, player1Wins: 2, player2Wins: 0, draws: 0)
      } else {
        viewModel.completeMatch(
          roundIndex: 0, matchIndex: i, player1Wins: 0, player2Wins: 2, draws: 0)
      }
    }

    #expect(
      round != viewModel.currentRound(),
      "After all matches have completed we should have moved to the next round")

    round = viewModel.currentRound()
    for match in round.matches {
      #expect(
        winnerNames.contains(match.player1.name) && winnerNames.contains(match.player2.name)
          || looserNames.contains(match.player1.name) && looserNames.contains(match.player2.name)
      )
    }
  }

  @Test("Test pairing across multiple rounds")
  func testPairingMultipleRounds() async throws {
    // Setup identical to first test
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)

    // Initial players - we'll track their expected records
    let playerNames = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Henry"]
    let players = playerNames.map { Player(name: $0) }
    players.forEach { modelContext.insert($0) }

    viewModel.startTournament(players: players)

    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }

    // Round 1: Alice, Bob, Charlie, David win
    var round = viewModel.currentRound()
    let winnersRoundOne = Set(round.matches.map { $0.player1.name })
    let losersRoundOne = Set(round.matches.map { $0.player2.name })
    for (i, match) in round.matches.enumerated() {
      // First 4 players win their matches
      let player1ShouldWin = winnersRoundOne.contains(match.player1.name)
      viewModel.completeMatch(
        roundIndex: 0,
        matchIndex: i,
        player1Wins: player1ShouldWin ? 2 : 0,
        player2Wins: player1ShouldWin ? 0 : 2,
        draws: 0
      )
    }

    // Round 2: Check winners play winners, losers play losers
    round = viewModel.currentRound()
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
    for (i, match) in round.matches.enumerated() {
      let player1ShouldWin = winnersRoundTwo.contains(match.player1.name)
      viewModel.completeMatch(
        roundIndex: 1,
        matchIndex: i,
        player1Wins: player1ShouldWin ? 2 : 0,
        player2Wins: player1ShouldWin ? 0 : 2,
        draws: 0
      )
    }

    let bothWon = winnersRoundOne.intersection(winnersRoundTwo)
    let bothLost = losersRoundOne.intersection(losersRoundTwo)
    let oneWonOneLost = Set(playerNames).subtracting(bothWon.union(bothLost))
    round = viewModel.currentRound()
    for match in round.matches {
      let both2_0 = [match.player1, match.player2].allSatisfy { bothWon.contains($0.name) }
      let both1_1 = [match.player1, match.player2].allSatisfy { oneWonOneLost.contains($0.name) }
      let both0_2 = [match.player1, match.player2].allSatisfy { bothLost.contains($0.name) }

      #expect(both2_0 || both1_1 || both0_2, "Round 3 should pair players based on overall records")
    }
  }
}
