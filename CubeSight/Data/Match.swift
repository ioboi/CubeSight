import Foundation
import SwiftData

@Model
class Match {
    var player1: Player
    var player2: Player?
    var player1Wins: Int = 0
    var player2Wins: Int = 0
    var draws: Int = 0
    var isComplete: Bool = false
    
    init(player1: Player, player2: Player?) {
        self.player1 = player1
        self.player2 = player2
    }
    
    func recordResult(player1Wins: Int, player2Wins: Int, draws: Int) {
        self.player1Wins = player1Wins
        self.player2Wins = player2Wins
        self.draws = draws
        self.isComplete = true
        
        // Update player scores
        player1.matchPoints += player1Wins * 3 + draws
        player1.gamePoints += player1Wins * 3 + draws
        
        if let player2 = player2 {
            player2.matchPoints += player2Wins * 3 + draws
            player2.gamePoints += player2Wins * 3 + draws
        } else {
            // Player 1 gets a bye
            player1.matchPoints += 3
            player1.gamePoints += 6
        }
    }
    
    func involves(_ player: Player) -> Bool {
        return player1 == player || player2 == player
    }
}
