import SwiftUI

struct EndedTournamentView: View {
  let tournament: Tournament

  @State private var isExportTournamentPresented = false

  var body: some View {
    List {
      NavigationLink("Standings") {
        StandingsView(tournament: tournament)
      }
      
      Section {
        Button("Export Tournament", systemImage: "square.and.arrow.up") { isExportTournamentPresented = true }
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
    .sheet(isPresented: $isExportTournamentPresented) {
      NavigationStack {
        TournamentExportView(tournament: tournament)
          .navigationTitle("Export Tournament")
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
