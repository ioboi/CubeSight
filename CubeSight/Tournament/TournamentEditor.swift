import SwiftData
import SwiftUI

struct TournamentEditor: View {
  let tournament: Tournament?

  @State private var date: Date = Date()
  @State private var selectedPlayers: Set<TournamentPlayer> = []
  @Environment(\.dismiss) var dismiss: DismissAction
  @Environment(\.modelContext) var modelContext: ModelContext

  private var editorTitle: String {
    tournament != nil ? "Edit Tournament" : "New Tournament"
  }

  var body: some View {
    NavigationStack {
      Form {
        DatePicker("Date", selection: $date, displayedComponents: [.date])
        Section {
          NavigationLink(
            destination: TournamentPlayerPicker(selection: $selectedPlayers)
          ) {
            Label("Select Players", systemImage: "person.3")
              .badge(selectedPlayers.count)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(editorTitle)
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            withAnimation {
              save()
              dismiss()
            }
          }
          // Require at least 2 players
          .disabled(selectedPlayers.count < 2)
        }

        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
      }
    }
    .onAppear {
      if let tournament {
        date = tournament.createdAt
        selectedPlayers = Set(tournament.players)
      }
    }
  }

  private func save() {
    if let tournament {
      tournament.createdAt = date
      tournament.players = Array(selectedPlayers)
    } else {
      let newTournament = Tournament(players: Array(selectedPlayers))
      newTournament.createdAt = date
      modelContext.insert(newTournament)
    }
  }
}

#Preview(traits: .sampleData) {
  TournamentEditor(tournament: nil)
}
