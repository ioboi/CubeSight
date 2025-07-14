import SwiftUI

struct CubeDeckEditor: View {
  let cube: Cube
  let deck: CubeDeck?

  private var editorTitle: String {
    deck == nil ? "Add Deck" : "Edit Deck"
  }

  @State private var name: String = ""
  @State private var createdAt: Date = Date()
  @State private var archetype: String = ""

  enum FocusedField: CaseIterable {
    case name
    case date
    case archetype
  }

  @FocusState
  private var focusedField: FocusedField?

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    NavigationStack {
      List {
        Section("Name") {
          TextField("Enter name", text: $name)
            .focused($focusedField, equals: .name)
        }
        DatePicker(
          "Date",
          selection: $createdAt,
          displayedComponents: [.date]
        )
        .focused($focusedField, equals: .date)
        .toolbar {
          ToolbarItem(placement: .keyboard) {
            Text("Hello")
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
          archetype = deck.archetype?.name ?? ""
        }
        //focusedField = .name
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

private struct DeckArchetypeSuggestions: View {
  let searchTerm: String
  let action: (DeckArchetype) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        ArchetypeSearchResults(searchTerm: searchTerm, fetchLimit: 10) {
          archetype in
          Button(archetype.name) {
            action(archetype)
          }
          .buttonStyle(.bordered)
        }
      }
    }
  }
}

#Preview("Add deck", traits: .sampleData) {
  CubeDeckEditor(cube: Cube.sampleCube, deck: nil)
}

#Preview("Archetypes suggestions", traits: .sampleData) {
  DeckArchetypeSuggestions(searchTerm: "") { _ in }
}
