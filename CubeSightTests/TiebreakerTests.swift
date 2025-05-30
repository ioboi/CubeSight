import Numerics
import SwiftData
import Testing

@testable import CubeSight

@MainActor
struct TiebreakerTests {
  let context: ModelContext

  init() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: TournamentPlayer.self, Tournament.self, TournamentRound.self, TournamentMatch.self, configurations: config)
    context = container.mainContext
  }

  @Test("Match points calculation")
  func testMatchPoints() throws {
    let players = [TournamentPlayer(name: "Player1"), TournamentPlayer(name: "Player2")]
    var tournament = Tournament(players: players)

    //    TODO: maybe make strategy a member var?

    // Simulate 6 wins, 2 losses for player1
    for _ in 0..<6 {
      tournament.startNextRound(strategy: SwissPairingStrategy())
      tournament.rounds.last?.matches.first?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
    }
    for _ in 0..<2 {
      tournament.startNextRound(strategy: SwissPairingStrategy())
      tournament.rounds.last?.matches.first?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
    }
    tournament.startNextRound(strategy: SwissPairingStrategy())

    #expect(
      tournament.getPerformance(for: players[0])?.matchPoints == 18,
      "Player with 6-2-0 record should have 18 match points")

    tournament = Tournament(players: players)

    // Simulate 4 wins, 2 losses, 2 draws for player2
    for i in 0..<8 {
      tournament.startNextRound(strategy: SwissPairingStrategy())
      let match = tournament.rounds.last?.matches.first
      if i < 4 {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        }
      } else if i < 6 {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        }
      } else {
        match?.complete(player1Wins: 1, player2Wins: 1, draws: 1)
      }
    }

    tournament.startNextRound(strategy: SwissPairingStrategy())
    #expect(
      tournament.getPerformance(for: players[1])?.matchPoints == 14,
      "Player with 4-2-2 record should have 14 match points")
  }

  @Test("Game points calculation")
  func testGamePoints() throws {
    let players = [TournamentPlayer(name: "Player1"), TournamentPlayer(name: "Player2")]
    let tournament = Tournament(players: players)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    tournament.rounds.last?.matches.first?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
    tournament.startNextRound(strategy: SwissPairingStrategy())
    #expect(
      tournament.getPerformance(for: players[0])?.gamePoints == 6,
      "Player winning a match 2-0-0 should have 6 game points")

    tournament.rounds.last?.matches.first?.complete(player1Wins: 2, player2Wins: 1, draws: 0)
    tournament.startNextRound(strategy: SwissPairingStrategy())
    #expect(
      tournament.getPerformance(for: players[0])?.gamePoints == 12,
      "Player winning matches 2-0-0 and 2-1-0 should have 12 game points")

    tournament.rounds.last?.matches.first?.complete(player1Wins: 2, player2Wins: 0, draws: 1)
    tournament.startNextRound(strategy: SwissPairingStrategy())
    #expect(
      tournament.getPerformance(for: players[0])?.gamePoints == 18,
      "Player winning matches 2-0-0, 2-1-0, and 2-0-1 should have 18 game points")
  }

  @Test("Match win percentage calculation")
  func testMatchWinPercentage() throws {
    let players = [TournamentPlayer(name: "Player1"), TournamentPlayer(name: "Player2")]
    var tournament = Tournament(players: players)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    // Simulate 5 wins, 2 losses, 1 draw
    for _ in 0..<5 {
      let match = tournament.rounds.last?.matches.first
      if match?.player1 == players[0] {
        match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
      } else {
        match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
      }
      tournament.startNextRound(strategy: SwissPairingStrategy())
    }
    for _ in 0..<2 {
      let match = tournament.rounds.last?.matches.first
      if match?.player1 == players[0] {
        match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
      } else {
        match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
      }
      tournament.startNextRound(strategy: SwissPairingStrategy())
    }

    tournament.rounds.last?.matches.first?.complete(player1Wins: 0, player2Wins: 0, draws: 1)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    #expect(
      (tournament.performance[players[0]]?.matchWinRate ?? 0).isApproximatelyEqual(to: 16.0 / 24.0),
      "Player with 5-2-1 record should have 5*3+1 / 8*3 = 0.667 match-win percentage")
    #expect(
      (tournament.performance[players[1]]?.matchWinRate ?? 0).isApproximatelyEqual(
        to: TournamentPlayerPerformance.miniumPercentage),
      "Player with 2-5-1 record should have 0.33 (minimum) match-win percentage")

    // Reset tournament
    tournament = Tournament(players: players)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    // Simulate 1 win, 3 losses for player 1
    for i in 0..<4 {
      let match = tournament.rounds.last?.matches.first
      if i == 0 {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        } else {
          match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        }
      } else {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        }
      }
      tournament.startNextRound(strategy: SwissPairingStrategy())
    }

    #expect(
      (tournament.performance[players[0]]?.matchWinRate ?? 0).isApproximatelyEqual(
        to: TournamentPlayerPerformance.miniumPercentage),
      "Player with 1-3-0 record in 4 rounds should have 0.33 match-win percentage (minimum)")
    #expect(
      (tournament.performance[players[1]]?.matchWinRate ?? 0).isApproximatelyEqual(to: 0.75),
      "Player with 3-1-0 record in 4 rounds should have 0.75 match-win percentage (minimum)")
  }

  @Test("Game win percentage calculation")
  func testGameWinPercentage() throws {
    let players = [TournamentPlayer(name: "Player1"), TournamentPlayer(name: "Player2")]
    var tournament = Tournament(players: players)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    // Simulate 7 game wins, 3 game losses
    for _ in 0..<3 {
      tournament.rounds.last?.matches.first?.complete(player1Wins: 2, player2Wins: 1, draws: 0)
      tournament.startNextRound(strategy: SwissPairingStrategy())
    }
    tournament.rounds.last?.matches.first?.complete(player1Wins: 1, player2Wins: 0, draws: 0)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    #expect(
      (tournament.performance[players[0]]?.gameWinRate ?? 0).isApproximatelyEqual(to: 0.7),
      "Player with 21 game points in 10 games should have 0.70 game-win percentage")
    #expect(
      (tournament.performance[players[1]]?.gameWinRate ?? 0).isApproximatelyEqual(
        to: TournamentPlayerPerformance.miniumPercentage),
      "Player with 9 game points in 10 games should have 0.33 game-win percentage")

    // Reset tournament
    tournament = Tournament(players: players)
    tournament.startNextRound(strategy: SwissPairingStrategy())

    // Simulate 3 game wins, 8 game losses
    for i in 0..<4 {
      let match = tournament.rounds.last?.matches.first
      if i < 3 {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 1, player2Wins: 2, draws: 0)
        } else {
          match?.complete(player1Wins: 2, player2Wins: 1, draws: 0)
        }
      } else {
        if match?.player1 == players[0] {
          match?.complete(player1Wins: 0, player2Wins: 2, draws: 0)
        } else {
          match?.complete(player1Wins: 2, player2Wins: 0, draws: 0)
        }
      }
      tournament.startNextRound(strategy: SwissPairingStrategy())
    }

    #expect(
      (tournament.getPerformance(for: players[0])?.gameWinRate ?? 0).isApproximatelyEqual(
        to: TournamentPlayerPerformance.miniumPercentage),
      "Player with 9 game points in 11 games should have 0.33 game-win percentage (minimum)")
    #expect(
      (tournament.getPerformance(for: players[1])?.gameWinRate ?? 0).isApproximatelyEqual(
        to: 24 / 33),
      "Player with 24 game points in 11 games should have 24/33 game-win percentage (minimum)")
  }
}
