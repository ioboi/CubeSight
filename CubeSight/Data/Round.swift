import Foundation
import SwiftData

@Model
class Round {
    let number: Int
    @Relationship(deleteRule: .cascade) var matches: [Match] = []
    
    init(number: Int, players: [Player], context: ModelContext) {
        self.number = number
        self.matches = []
        
        let players = number == 1 ? players.shuffled() : players.sorted { p1, p2 in
            if p1.matchPoints != p2.matchPoints {
                return p1.matchPoints > p2.matchPoints
            }
            return p1.opponentMatchWinPercentage > p2.opponentMatchWinPercentage
        }
        
        // Pair players and create matches within the same context
        let pairedMatches = Round.pairPlayers(players)
        for matchPair in pairedMatches {
            let match = Match(player1: matchPair.0, player2: matchPair.1)
            context.insert(match)
            self.matches.append(match)
        }
    }
    
    static func pairPlayers(_ players: [Player]) -> [(Player, Player?)] {
        var pairs: [(Player, Player?)] = []
        var unmatchedPlayers = players
        
        while unmatchedPlayers.count >= 2 {
            let player1 = unmatchedPlayers.removeFirst()
            
            // Find the highest ranked player that player1 hasn't played yet
            if let opponentIndex = unmatchedPlayers.firstIndex(where: { player in
                !player1.matches.contains { $0.involves(player) }
            }) {
                let player2 = unmatchedPlayers.remove(at: opponentIndex)
                pairs.append((player1, player2))
            } else {
                // If all remaining players have been played, pair with the next available player
                let player2 = unmatchedPlayers.removeFirst()
                pairs.append((player1, player2))
            }
        }
        
        // If there's an odd number of players, the last player gets a bye
        if let lastPlayer = unmatchedPlayers.first {
            pairs.append((lastPlayer, nil))
        }
        
        return pairs
    }
}
