import Foundation
import SwiftData

@Model
class Tournament {
    @Attribute(.unique) var id: UUID
    var name: String
    var season: Int
    var draft: Int
    var rounds: Int
    var players: [Player] = []
    var currentRound: Int = 0
    
    init(id: UUID = UUID(), name: String, season: Int, draft: Int, rounds: Int) {
        self.id = id
        self.name = name
        self.season = season
        self.draft = draft
        self.rounds = rounds
    }
}

@Model
class Player {
    @Attribute(.unique) var id: UUID
    var name: String
    var matchPoints: Int = 0
    var gamePoints: Int = 0
    var matchWinPercentage: Double = 0.33
    var gameWinPercentage: Double = 0.33
    var opponentMatchWinPercentage: Double = 0.0
    var opponentGameWinPercentage: Double = 0.0
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@Model
class Round {
    var number: Int
    var matches: [Match] = []
    
    init(number: Int) {
        self.number = number
    }
}

@Model
class Match {
    var player1: Player
    var player2: Player
    var player1Wins: Int = 0
    var player2Wins: Int = 0
    var draws: Int = 0
    
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
    }
}
