import SwiftData
import SwiftUI

struct TournamentNavigationStack: View {
  @Query(sort: \Tournament.createdAt, order: .reverse) private var tournaments:
    [Tournament]
  @State private var isTournamentSetupPresented = false
  @Environment(\.modelContext) var modelContext: ModelContext

  var body: some View {
    NavigationStack {
      List {
        ForEach(tournaments) { tournament in
          NavigationLink(value: tournament) {
            TournamentRow(tournament: tournament)
          }
        }
        .onDelete(perform: deleteTournaments)
      }
      .navigationDestination(
        for: CubeDeck.self,
        destination: { cubeDeck in
          CubeDeckDetailView(deck: cubeDeck)
        }
      )
      .toolbar {
        Button(
          "Add tournament",
          systemImage: "plus",
          action: showTournamentSetup
        )
      }
      .sheet(isPresented: $isTournamentSetupPresented) {
        TournamentEditor(tournament: nil)
      }
      .navigationTitle("Tournaments")
      .navigationDestination(for: Tournament.self) { tournament in
        TournamentView(tournament: tournament)
      }
    }
  }

  private func deleteTournaments(indexSet: IndexSet) {
    for index in indexSet {
      modelContext.delete(tournaments[index])
    }
  }

  private func showTournamentSetup() {
    self.isTournamentSetupPresented = true
  }
}

#Preview(traits: .sampleData) {
  TournamentNavigationStack()
}
