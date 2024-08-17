import SwiftUI
import SwiftData

struct RoundView: View {
    @Bindable var round: Round
    @State private var showingConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(Array(round.matches.enumerated()), id: \.element.id) { index, match in
                NavigationLink(destination: MatchResultView(match: match)) {
                    MatchRowView(match: match, matchIndex: index + 1)
                }
            }
        }
        .navigationTitle("Round \(round.number)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish Round") {
                    dismiss()
                }
                .disabled(!allMatchesComplete())
                .accessibilityLabel("Finish Round \(round.number)")
                .accessibilityHint("Completes the current round and updates standings")
            }
        }
    }
    
    private func allMatchesComplete() -> Bool {
        round.matches.allSatisfy { $0.isComplete }
    }
}


//
//#Preview {
//    let modelContainer = try! ModelContainer(for: Tournament.self, Player.self, Round.self, Match.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//    
//    let tournament = Tournament(name: "Sample Tournament", season: 1, draft: 1, rounds: 3)
//    let players = [
//        Player(name: "Alice"),
//        Player(name: "Bob"),
//        Player(name: "Charlie"),
//        Player(name: "David")
//    ]
//    tournament.players = players
//    
//    let round = Round(number: 1, players: tournament.players)
//    
//    return NavigationView {
//        RoundView(round: round, tournament: tournament)
//    }
//    .modelContainer(modelContainer)
//}
