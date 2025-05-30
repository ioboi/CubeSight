import SwiftData
import SwiftUI

struct TournamentNavigationStack: View {
  @Query(sort: \Tournament.createdAt, order: .reverse) private var tournaments:
    [Tournament]
  @State private var isTournamentSetupPresented = false

  var body: some View {
    NavigationStack {
      List(tournaments) { tournament in
        NavigationLink(value: tournament) {
          TournamentRow(tournament: tournament)
        }
      }
      .toolbar {
        Button(
          "Add tournament",
          systemImage: "plus",
          action: showTournamentSetup
        )
      }
      .sheet(isPresented: $isTournamentSetupPresented) {
        TournamentSetupView()
      }
      .navigationTitle("Tournaments")
      .navigationDestination(for: Tournament.self) { tournament in
        TournamentView(tournament: tournament)
      }
    }
  }

  private func showTournamentSetup() {
    self.isTournamentSetupPresented = true
  }
}

#Preview(traits: .sampleData) {
  TournamentNavigationStack()
}
