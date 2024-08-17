import SwiftUI
import SwiftData

struct TournamentView: View {
    @Bindable var tournament: Tournament
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    
    var body: some View {
        List {
            Section("Tournament Info") {
                Text("Season: \(tournament.season)")
                Text("Draft: \(tournament.draft)")
                Text("Rounds: \(tournament.rounds)")
                Text("Current Round: \(tournament.currentRound)")
            }
            
            Section("Players") {
                ForEach(tournament.players) { player in
                    Text(player.name)
                }
                Button("Add Player") {
                    showingAddPlayer = true
                }
            }
            
            if tournament.currentRound < tournament.rounds {
                Button("Start Next Round") {
                    startNextRound()
                }
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            NavigationView {
                Form {
                    TextField("Player Name", text: $newPlayerName)
                    Button("Add") {
                        addPlayer()
                    }
                }
                .navigationTitle("Add Player")
            }
        }
    }
    
    private func addPlayer() {
        let newPlayer = Player(name: newPlayerName)
        tournament.players.append(newPlayer)
        newPlayerName = ""
        showingAddPlayer = false
    }
    
    private func startNextRound() {
        // Implement pairing logic here
        tournament.currentRound += 1
    }
}

struct CreateTournamentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var season = 1
    @State private var draft = 1
    @State private var rounds = 3
    
    var body: some View {
        Form {
            TextField("Tournament Name", text: $name)
            Stepper("Season: \(season)", value: $season, in: 1...100)
            Stepper("Draft: \(draft)", value: $draft, in: 1...100)
            Stepper("Rounds: \(rounds)", value: $rounds, in: 3...10)
            
            Button("Create Tournament") {
                let newTournament = Tournament(name: name, season: season, draft: draft, rounds: rounds)
                modelContext.insert(newTournament)
                dismiss()
            }
        }
        .navigationTitle("Create Tournament")
    }
}

#Preview {
    TournamentView(tournament: Tournament(name: "Sample Tournament", season: 1, draft: 1, rounds: 3))
        .modelContainer(for: [Tournament.self, Player.self], inMemory: true)
}
