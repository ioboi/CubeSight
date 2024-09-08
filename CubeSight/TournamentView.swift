import SwiftUI
import SwiftData

struct TournamentView: View {
    @Bindable var tournament: Tournament
    @Environment(\.modelContext) private var context
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    @State private var navigateToNewRound: Bool = false
    @State private var newRound: Round?
    
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
                Button("Add 8 Players") {
                                    addEightPlayers()
                                }.disabled(tournament.players.count > 0)
            }
            
            Section("Rounds") {
                ForEach(tournament.completedRounds.sorted(by: { $0.number < $1.number }), id: \.number) { round in
//                    TODO: editing rounds can lead to wrong standings
                    NavigationLink("Round \(round.number)", destination: RoundView(round: round))
                }
                
                if tournament.currentRound < tournament.rounds && tournament.players.count >= 4 {
                    Button("Start Next Round") {
                        if let createdRound = tournament.createNextRound(context: context) {
                            self.newRound = createdRound
                            self.navigateToNewRound = true
                        }
                    }
                }
            }
            
            Section {
                NavigationLink("View Standings", destination: StandingsView(tournament: tournament))
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
        .navigationTitle(tournament.name)
        .navigationDestination(isPresented: $navigateToNewRound) {
            if let round = newRound {
                RoundView(round: round)
            }
        }
    }
    
    private func addPlayer() {
        let newPlayer = Player(name: newPlayerName)
        tournament.players.append(newPlayer)
        newPlayerName = ""
        showingAddPlayer = false
    }
    private func addEightPlayers() {
            let playerNames = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Henry"]
            for name in playerNames {
                let newPlayer = Player(name: name)
                tournament.players.append(newPlayer)
            }
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
    let tournament = Tournament(name: "Sample Tournament", season: 1, draft: 1, rounds: 3)
    tournament.players = [Player(name: "Alice"), Player(name: "Bob")]
    return TournamentView(tournament: tournament)
        .modelContainer(for: [Tournament.self, Player.self, Round.self, Match.self], inMemory: true)
}
