import SwiftUI

struct CubeDeckEditor: View {
  let cube: Cube
  let deck: CubeDeck?

  private var editorTitle: String {
    deck == nil ? "Add Deck" : "Edit Deck"
  }

  @State private var name: String = ""
  @State private var createdAt: Date = Date()
  @FocusState private var nameFieldIsFocused: Bool

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    NavigationStack {
      Form {
        TextField("Name", text: $name)
          .focused($nameFieldIsFocused)
        DatePicker(
          "Created At",
          selection: $createdAt,
          displayedComponents: [.date]
        )
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
      .onAppear {
        if let deck {
          name = deck.name
          createdAt = deck.createdAt
        }
        nameFieldIsFocused = true
      }
    }
  }

  private func save() {
    if let deck = deck {
      deck.name = name
      deck.createdAt = createdAt
    } else {
      let newDeck = CubeDeck(cube: cube, name: name, createdAt: createdAt)
      modelContext.insert(newDeck)
      // TODO: Check if this is needed with autosave. Currently without explicit save, related deck lists do not refresh.
      try? modelContext.save()
    }
  }
}

#Preview("Add deck", traits: .sampleData) {
  CubeDeckEditor(cube: Cube.sampleCube, deck: nil)
}
