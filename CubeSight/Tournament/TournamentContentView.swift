import SwiftData
import SwiftUI

struct TournamentContentView: View {
  @Query(sort: \Tournament.createdAt, order: .reverse) var tournaments: [Tournament]
  @State private var showingSetupSheet = false

  var body: some View {
    NavigationStack {
      List {
        ForEach(tournaments) { tournament in
          NavigationLink(value: tournament) {
            TournamentRowView(tournament: tournament)
          }
        }
      }
      .navigationTitle("Tournaments")
      .navigationDestination(for: Tournament.self) { tournament in
        TournamentView(tournament: tournament)
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: { showingSetupSheet = true }) {
            Image(systemName: "plus.circle.fill")
              .imageScale(.large)
          }
        }
      }
      .sheet(isPresented: $showingSetupSheet) {
        TournamentSetupView()
      }
    }
  }
}

struct TournamentRowView: View {
  let tournament: Tournament

  var body: some View {
    HStack {
      Label(
        "\(tournament.players.count) participants",
        systemImage: "person.3")
      Spacer()
      Text(tournament.createdAt, style: .date)
        .foregroundStyle(.secondary)
    }
    .font(.subheadline)
  }
}

#Preview {
  TournamentContentView()
    .modelContainer(for: Tournament.self, inMemory: true)
}
