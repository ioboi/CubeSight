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
    } else {
      // TODO: Change constructor to only need "createdAt".
      // TODO: Players will be set in "seating"
      let newTournament = Tournament(players: [])
      newTournament.createdAt = date
      modelContext.insert(newTournament)
      try? modelContext.save()
    }
  }
}

#Preview(traits: .sampleData) {
  TournamentEditor(tournament: nil)
}
