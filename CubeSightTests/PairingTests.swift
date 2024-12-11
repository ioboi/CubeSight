//
//  PairingTests.swift
//  CubeSightTests
//
//  Created by Noe on 11.12.2024.
//

import Testing
import SwiftData
import Numerics

@testable import CubeSight

@MainActor
struct PairingTests {

    @Test("Test looser and winner pairing one round")
    func testPairing() async throws {
      let config = ModelConfiguration(isStoredInMemoryOnly: true)
      let container = try ModelContainer(for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
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
          viewModel.completeMatch(roundIndex: 0, matchIndex: i, player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: 0, matchIndex: i, player1Wins: 0, player2Wins: 2, draws: 0)
        }
      }
      #expect(round != viewModel.currentRound(), "After all matches have completed we should have moved to the next round")
      
      round = viewModel.currentRound()
      for match in round.matches {
        #expect(
          winnerNames.contains(match.player1.name) && winnerNames.contains(match.player2.name) ||
          looserNames.contains(match.player1.name) && looserNames.contains(match.player2.name)
        )
      }
    }
}
