import SwiftData
import SwiftUI

struct TournamentSetupView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Query private var existingPlayers: [Player]

  // Track selected existing players and new player names separately
  @State private var selectedPlayers: Set<Player> = []
  @State private var newPlayerNames: [String] = []
  @State private var showingAddPlayer = false

  var body: some View {
    NavigationStack {
      Form {
        Section("Existing Players") {
          if existingPlayers.isEmpty {
            Text("No existing players")
              .foregroundStyle(.secondary)
          } else {
            ForEach(existingPlayers) { player in
              Toggle(
                isOn: Binding(
                  get: { selectedPlayers.contains(player) },
                  set: { isSelected in
                    if isSelected {
                      selectedPlayers.insert(player)
                    } else {
                      selectedPlayers.remove(player)
                    }
                  }
                )
              ) {
                Text(player.name)
              }
            }
          }
        }

        Section("New Players") {
          ForEach($newPlayerNames.indices, id: \.self) { index in
            TextField("Player Name", text: $newPlayerNames[index])
          }
          .onDelete { indexSet in
            newPlayerNames.remove(atOffsets: indexSet)
          }

          Button(action: {
            newPlayerNames.append("")
          }) {
            Label("Add New Player", systemImage: "plus.circle.fill")
          }
        }
      }
      .navigationTitle("New Tournament")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Create") {
            createTournament()
          }
        }
      }
    }
  }

  private func createTournament() {
    // Create and add new players
    let newPlayers =
      newPlayerNames
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
      .map { Player(name: $0) }

    newPlayers.forEach { modelContext.insert($0) }

    // Combine selected and new players
    let allPlayers = selectedPlayers + newPlayers

    guard allPlayers.count >= 2 else { return }

    let tournament = Tournament(players: Array(allPlayers))
    tournament.startNextRound(strategy: SwissPairingStrategy())
    modelContext.insert(tournament)
    dismiss()
  }
}
