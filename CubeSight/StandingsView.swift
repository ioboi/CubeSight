import SwiftUI
import SwiftData

struct StandingsView: View {
    @Bindable var tournament: Tournament
    
    var body: some View {
        List {
            ForEach(Array(tournament.players.enumerated()), id: \.element.id) { index, player in
                HStack {
                    Text("\(index + 1)")
                        .frame(width: 30, alignment: .leading)
                    Text(player.name)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(player.matchPoints) pts")
                            .font(.headline)
                        Text(String(format: "%.2f%%", player.matchWinPercentage * 100))
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Standings")
        .onAppear {
            tournament.calculateStandings()
        }
    }
}

#Preview {
    let tournament = Tournament(name: "Sample Tournament", season: 1, draft: 1, rounds: 3)
    tournament.players = [
        Player(name: "Alice"),
        Player(name: "Bob"),
        Player(name: "Charlie"),
        Player(name: "David")
    ]
    // Simulate some results
    tournament.players[0].matchPoints = 9
    tournament.players[1].matchPoints = 6
    tournament.players[2].matchPoints = 3
    tournament.players[3].matchPoints = 0
    return StandingsView(tournament: tournament)
        .modelContainer(for: [Tournament.self, Player.self], inMemory: true)
}
