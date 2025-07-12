import SwiftData
import SwiftUI

struct SeatingTournamentView: View {
  var tournament: Tournament

  @Environment(\.modelContext) private var modelContext: ModelContext
  @State private var selectedPlayers: Set<Player> = []
  @State private var isPlayerPickerPresented: Bool = false

  var body: some View {
    List {
      SeatingView(tournament: tournament)
      if tournament.players.isEmpty {
        Button("Add players", systemImage: "person.badge.plus") {
          isPlayerPickerPresented = true
        }
      }
      if tournament.players.count > 2 {
        Section {
          Button("Randomize seatings", systemImage: "dice") {
            withAnimation {
              // TODO: Check if correct
              for (offset, player) in tournament.players.shuffled().enumerated()
              {
                player.seating = offset
              }
            }
            try? modelContext.save()
          }
        }
      }
      Section {
        Button("Pair round 1", systemImage: "person.2") {
          tournament.startNextRound()
          tournament.status = .ongoing
        }
        .disabled(
          tournament.players.count < 2 || tournament.players.count % 2 != 0
        )  // A tournament must have at least 2 players
      }
      .onChange(of: selectedPlayers) { _, newValue in
        tournament.players =
          newValue.enumerated()
          .map { offset, player in
            let tournamentPlayer = TournamentPlayer(player: player)
            tournamentPlayer.seating = offset
            return tournamentPlayer
          }

      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Edit") { isPlayerPickerPresented = true }
      }
    }
    .navigationTitle("Players (\(tournament.players.count))")
    .sheet(isPresented: $isPlayerPickerPresented) {
      NavigationStack {
        PlayerPicker(selection: $selectedPlayers)
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              Button("Done") {
                isPlayerPickerPresented = false
              }
            }
          }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  NavigationStack {
    SeatingTournamentView(tournament: Tournament.previewTournament)
  }
}
