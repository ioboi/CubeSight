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
    @Relationship(deleteRule: .cascade) var completedRounds: [Round] = []
    
    init(id: UUID = UUID(), name: String, season: Int, draft: Int, rounds: Int) {
        self.id = id
        self.name = name
        self.season = season
        self.draft = draft
        self.rounds = rounds
    }
    
    func createNextRound(context: ModelContext) -> Round? {
        guard currentRound < rounds else { return nil }
        currentRound += 1
        let newRound = Round(number: currentRound, players: players, context: context)
        completedRounds.append(newRound)
        return newRound
    }
    
    func calculateStandings() {
        for player in players {
            player.calculateTiebreakers(totalRounds: currentRound)
        }
        players.sort { $0.matchPoints > $1.matchPoints }
    }
}
