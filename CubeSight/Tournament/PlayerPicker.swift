import SwiftData
import SwiftUI

struct PlayerPicker: View {
  @Binding var selection: Set<Player>
  @Query(sort: [SortDescriptor(\Player.name)]) private var availablePlayers:
    [Player]
  @Environment(\.modelContext) private var modelContext: ModelContext

  @State private var newPlayerName: String = ""

  var body: some View {
    List {
      Section {
        ForEach(availablePlayers) { player in
          Button(action: { selectOrDeselect(player: player) }) {
            HStack {
              Label(
                player.name,
                systemImage: selection.contains(player)
                  ? "checkmark.circle.fill" : "circle"
              )
              .tint(.primary)
              Spacer()
              if player.tournaments.count == 0 {
                Image(systemName: "person.fill.badge.plus")
              }
            }
          }
          .deleteDisabled(player.tournaments.count > 0)
        }
        .onDelete(perform: deletePlayers)

        TextField("New Player", text: $newPlayerName)
          .submitLabel(.return)
          .onSubmit {
            withAnimation {
              addNewPlayer()
            }
          }
      } footer: {
        Text(
          "You can only remove players that have not been assigned to any tournaments \(Image(systemName: "person.fill.badge.plus"))."
        )
      }
    }
    .navigationTitle("(\(selection.count)) Selected Players")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func deletePlayers(indexSet: IndexSet) {
    for index in indexSet {
      let player = availablePlayers[index]
      selection.remove(player)
      modelContext.delete(player)
    }
  }

  private func selectOrDeselect(player: Player) {
    if selection.contains(player) {
      selection.remove(player)
    } else {
      selection.insert(player)
    }
  }

  private func addNewPlayer() {
    guard !newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else { return }
    let newPlayer = Player(
      name: newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
    )
    modelContext.insert(newPlayer)
    selection.insert(newPlayer)
    newPlayerName = ""
  }
}

#Preview(traits: .sampleData) {
  @Previewable @State var selection: Set<Player> = []
  NavigationStack {
    PlayerPicker(selection: $selection)
  }
}
