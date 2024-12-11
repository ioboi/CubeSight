//
//  Match.swift
//  CubeSight
//
//  Created by Noe Thalheim on 23.09.2024.
//

import SwiftData


@Model
class Match {
  var player1: Player
  var player2: Player
  var player1Wins: Int
  var player2Wins: Int
  var draws: Int
  var winner: Player?

  init(player1: Player, player2: Player) {
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

  //  TODO(performance): test with borrowing / inout
  func process(into performance: inout [Player: PlayerPerformance]) {
    guard var performance1 = performance[player1],
      var performance2 = performance[player2]
    else {
      //      TODO(log): maybe we want to log this event?
      //      TODO(bye): support
      return  // Skip if either player's performance is not found
    }

    // Update player 1 performance
    performance1.gameWins += player1Wins
    performance1.gameLosses += player2Wins
    performance1.opponents.append(player2)

    // Update player 2 performance
    performance2.gameWins += player2Wins
    performance2.gameLosses += player1Wins
    performance2.opponents.append(player1)

    // Update match results
    if winner != nil {
      if player1Wins > player2Wins {
        performance1.matchWins += 1
        performance2.matchLosses += 1
      } else {
        performance1.matchLosses += 1
        performance2.matchWins += 1
      }
    }

    performance1.draws += draws
    performance2.draws += draws
    
    performance[player1] = performance1
    performance[player2] = performance2
  }
}
