
import SwiftData
import Testing
import Numerics

@testable import CubeSight

@MainActor
struct TiebreakerTests {
  
  @Test("Match points calculation")
  func testMatchPoints() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)
    
    let players = [Player(name: "Player1"), Player(name: "Player2")]
    players.forEach { modelContext.insert($0) }
    
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    // Simulate 6 wins, 2 losses for player1
    for i in 0..<8 {
      viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: i < 6 ? 2 : 0, player2Wins: i < 6 ? 0 : 2, draws: 0)
    }
    
    
    #expect(tournament.performance[players[0]]?.matchPoints == 18, "Player with 6-2-0 record should have 18 match points")
    
    // Reset tournament
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let newTournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    // Simulate 4 wins, 2 losses, 2 draws for player2
    for i in 0..<8 {
      let round = viewModel.currentRound()
      let match = round.matches[0]
      if i < 4 {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        }
      } else if i < 6 {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        }
      } else {
        viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 1, player2Wins: 1, draws: 1)
      }
    }
    
    #expect(newTournament.performance[players[1]]?.matchPoints == 14, "Player with 4-2-2 record should have 14 match points")
  }
  
  @Test("Game points calculation")
  func testGamePoints() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)
    
    let players = [Player(name: "Player1"), Player(name: "Player2")]
    
    
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    viewModel.completeMatch(roundIndex: 0, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
    #expect(tournament.performance[players[0]]?.gamePoints == 6, "Player winning a match 2-0-0 should have 6 game points")
    
    viewModel.completeMatch(roundIndex: 1, matchIndex: 0, player1Wins: 2, player2Wins: 1, draws: 0)
    #expect(tournament.performance[players[0]]?.gamePoints == 12, "Player winning matches 2-0-0 and 2-1-0 should have 12 game points")
    
    viewModel.completeMatch(roundIndex: 2, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 1)
    #expect(tournament.performance[players[0]]?.gamePoints == 19, "Player winning matches 2-0-0, 2-1-0, and 2-0-1 should have 19 game points")
  }
  
  @Test("Match win percentage calculation")
  func testMatchWinPercentage() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)
    
    let players = [Player(name: "Player1"), Player(name: "Player2")]
    players.forEach { modelContext.insert($0) }
    
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    // Simulate 5 wins, 2 losses, 1 draw
    for i in 0..<8 {
      let round = viewModel.currentRound()
      let match = round.matches[0]
      if i < 5 {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        }
        viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
      } else if i < 7 {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        }
      } else {
        viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 0, draws: 1)
      }
    }
    
    #expect((tournament.performance[players[0]]?.matchWinRate ?? 0).isApproximatelyEqual(to: 16.0/24.0), "Player with 5-2-1 record should have 5*3+1 / 8*3 = 0.667 match-win percentage")
    #expect((tournament.performance[players[1]]?.matchWinRate ?? 0).isApproximatelyEqual(to: PlayerPerformance.miniumPercentage), "Player with 2-5-1 record should have 0.33 (minimum) match-win percentage")

    // Reset tournament
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    
    // Simulate 1 win, 3 losses for player 1
    for i in 0..<4 {
      let round = viewModel.currentRound()
      let match = round.matches[0]
      if i == 0 {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        }
      } else {
        if match.player1 == players[0] {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 0, draws: 0)
        }
      }
    }
    
    #expect((tournament.performance[players[0]]?.matchWinRate ?? 0).isApproximatelyEqual(to: PlayerPerformance.miniumPercentage), "Player with 1-3-0 record in 4 rounds should have 0.33 match-win percentage (minimum)")
    #expect((tournament.performance[players[1]]?.matchWinRate ?? 0).isApproximatelyEqual(to: 0.75), "Player with 3-1-0 record in 4 rounds should have 0.75 match-win percentage (minimum)")
  }
  
  @Test("Game win percentage calculation")
  func testGameWinPercentage() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Player.self, Tournament.self, Round.self, Match.self, configurations: config)
    let modelContext = container.mainContext
    let viewModel = TournamentViewModel(modelContext: modelContext)
    
    let players = [Player(name: "Player1"), Player(name: "Player2")]
    players.forEach { modelContext.insert($0) }
    
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    // Simulate 7 game wins, 3 game losses
    for i in 0..<4 {
      if i < 3 {
        viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 2, player2Wins: 1, draws: 0)
      } else {
        viewModel.completeMatch(roundIndex: i, matchIndex: 0, player1Wins: 1, player2Wins: 0, draws: 0)
      }
    }
    
    #expect((tournament.performance[players[0]]?.gameWinRate ?? 0).isApproximatelyEqual(to: 0.7), "Player with 21 game points in 10 games should have 0.70 game-win percentage")
    
    // Reset tournament
    viewModel.startTournament(players: players)
    
    guard case .inProgress(let tournament) = viewModel.state else {
      Issue.record("Tournament should be in progress")
      return
    }
    
    // Simulate 3 game wins, 8 game losses
    for i in 0..<4 {
      let round = viewModel.currentRound()
      let match = round.matches[0]
      if i < 3 {
        if match.player1 == players[0] {
          match.complete(player1Wins: 1, player2Wins: 2, draws: 0)
        } else {
          match.complete(player1Wins: 2, player2Wins: 1, draws: 0)
        }
      } else {
        if match.player1 == players[0] {
          match.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          match.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        }
      }
    }
    
    #expect((tournament.performance[players[1]]?.gameWinRate ?? 0).isApproximatelyEqual(to: 0.33), "Player with 9 game points in 11 games should have 0.33 game-win percentage (minimum)")
  }
  
//  private func simulate(viewModel: TournamentViewModel, rounds: Int, wins: Int, losses: Int, draws: Int) {
//    assert(rounds == wins + losses + draws)
//    for i in 0..<rounds {
//      let round = viewModel.currentRound()
//      let match = round.matches[0]
//    }
//  }
}
