import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Query var cubes: [Cube]
    @Query var tournaments: [Tournament]
    @State private var importing = false
    @State private var creatingTournament = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Cubes") {
                    NavigationLink(destination: TextRecognitionView()) {
                        Label("Card Text Recognition", systemImage: "text.viewfinder")
                    }
                    ForEach(cubes) { cube in
                        NavigationLink(cube.name, destination: CubeView(cube: cube).navigationTitle(cube.name))
                    }
                }
                Section("Tournaments") {
                    ForEach(tournaments) { tournament in
                        NavigationLink(tournament.name, destination: TournamentView(tournament: tournament).navigationTitle(tournament.name))
                    }
                    Button(action: { creatingTournament = true }) {
                        Label("Create Tournament", systemImage: "plus")
                    }
                }
            }.overlay {
                if cubes.isEmpty && tournaments.isEmpty {
                    ContentUnavailableView {
                        Text("No Cubes or Tournaments")
                    } description: {
                        Text("Import cubes from Cube Cobra or create a new tournament.")
                    } actions: {
                        Button(action: { importing = true }) {
                            Label("Import \"Vintage Cube Season 4\"", systemImage: "square.and.arrow.down")
                        }
                        Button(action: { creatingTournament = true }) {
                            Label("Create Tournament", systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $importing) {
                NavigationStack {
                    ImportCubeView(shortId: "dimlas4")
                }.interactiveDismissDisabled()
            }
            .sheet(isPresented: $creatingTournament) {
                NavigationStack {
                    CreateTournamentView()
                }
            }
            .navigationTitle("Cubes")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Card.self, Cube.self, Tournament.self], inMemory: true)
}
