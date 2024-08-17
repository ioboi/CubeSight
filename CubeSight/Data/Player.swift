import Foundation
import SwiftData

@Model
class Player {
    let id: UUID
    var name: String
    var matchPoints: Int
    var gamePoints: Int
    var matchWinPercentage: Double
    var gameWinPercentage: Double
    var opponentMatchWinPercentage: Double
    var opponentGameWinPercentage: Double
    @Relationship(deleteRule: .cascade) var matches: [Match]
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.matchPoints = 0
        self.gamePoints = 0
        self.matchWinPercentage = 0
        self.gameWinPercentage = 0
        self.opponentMatchWinPercentage = 0
        self.opponentGameWinPercentage = 0
        self.matches = []
    }
    
    func calculateTiebreakers(totalRounds: Int) {
        let matchesPlayed = matches.count
        let gamesPlayed = matches.reduce(0) { $0 + $1.player1Wins + $1.player2Wins + $1.draws }
        
        matchWinPercentage = max(Double(matchPoints) / (Double(matchesPlayed) * 3.0), 0.33)
        gameWinPercentage = max(Double(gamePoints) / (Double(gamesPlayed) * 3.0), 0.33)
        
        let opponents = matches.compactMap { $0.player1 == self ? $0.player2 : $0.player1 }
        opponentMatchWinPercentage = opponents.reduce(0.0) { $0 + $1.matchWinPercentage } / Double(opponents.count)
        opponentGameWinPercentage = opponents.reduce(0.0) { $0 + $1.gameWinPercentage } / Double(opponents.count)
    }
}
