import SwiftUI
import SwiftData

struct RoundView: View {
    @Bindable var round: Round
    @Environment(\.modelContext) private var context
    @Bindable var tournament: Tournament
    @State private var showingConfirmation = false
    
    var body: some View {
        List {
            ForEach(round.matches) { match in
                MatchView(match: match)
            }
        }
        .navigationTitle("Round \(round.number)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish Round") {
                    showingConfirmation = true
                }
                .disabled(!allMatchesComplete())
            }
        }
        .alert("Finish Round", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                finishRound()
            }
        } message: {
            Text("Are you sure you want to finish this round? This will update player standings and cannot be undone.")
        }
    }
    
    private func allMatchesComplete() -> Bool {
        round.matches.allSatisfy { $0.isComplete }
    }
    
    private func finishRound() {
        tournament.calculateStandings()
        if tournament.currentRound < tournament.rounds {
            _ = tournament.createNextRound(context: context)
        }
    }
}

struct MatchView: View {
    @Bindable var match: Match
    @State private var player1Wins = 0
    @State private var player2Wins = 0
    @State private var draws = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(matchTitle)
                .font(.headline)
            
            if !match.isComplete {
                HStack {
                    Stepper("P1 Wins: \(player1Wins)", value: $player1Wins, in: 0...2)
                    Stepper("P2 Wins: \(player2Wins)", value: $player2Wins, in: 0...2)
                    Stepper("Draws: \(draws)", value: $draws, in: 0...3)
                }
                
                Button("Record Result") {
                    match.recordResult(player1Wins: player1Wins, player2Wins: player2Wins, draws: draws)
                }
                .disabled(!isValidResult())
            } else {
                Text("Result: \(match.player1Wins)-\(match.player2Wins)-\(match.draws)")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 5)
    }
    
    private var matchTitle: String {
        if let player2 = match.player2 {
            return "\(match.player1.name) vs \(player2.name)"
        } else {
            return "\(match.player1.name) - Bye"
        }
    }
    
    private func isValidResult() -> Bool {
        return player1Wins + player2Wins + draws == 3
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
