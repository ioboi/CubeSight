import Foundation
import SwiftData

@Model class TournamentMatch {
  var player1: TournamentPlayer
  var player2: TournamentPlayer
  var player1Wins: Int
  var player2Wins: Int
  var draws: Int
  var winner: TournamentPlayer?

  init(player1: TournamentPlayer, player2: TournamentPlayer) {
    self.player1 = player1
    self.player2 = player2
    self.player1Wins = 0
    self.player2Wins = 0
    self.draws = 0
  }

  func isComplete() -> Bool {
    return winner != nil || player1Wins + player2Wins + draws > 0
  }

  func complete(player1Wins: Int, player2Wins: Int, draws: Int) {
    self.player1Wins = player1Wins
    self.player2Wins = player2Wins
    self.draws = draws

    if player1Wins > player2Wins {
      winner = player1
    } else if player2Wins > player1Wins {
      winner = player2
    } else {
      winner = nil
    }
  }
}
