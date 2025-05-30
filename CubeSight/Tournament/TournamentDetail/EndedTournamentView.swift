import SwiftUI

struct EndedTournamentView: View {
  let tournament: Tournament

  var body: some View {
    List {
      NavigationLink("Standings") {
        StandingsView(tournament: tournament)
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Tournament")
      }
      ToolbarItem(placement: .primaryAction) {
        Button("Reopen", action: reopen)
      }
    }
  }

  private func reopen() {
    tournament.status = .ongoing
  }
}

#Preview(traits: .sampleData) {
  NavigationStack {
    EndedTournamentView(tournament: Tournament.previewTournament)
  }
}
