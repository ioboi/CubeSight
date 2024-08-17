import SwiftData
import SwiftUI

struct DeckEditor: View {
  let cube: Cube
  let deck: Deck?

  private var editorTitle: String {
    deck == nil ? "Add Deck" : "Edit Deck"
  }

  @State private var createdAt: Date = Date()
  @State private var name = ""

  @State private var cards: [Card] = []

  @State private var cardPickerSelection: [Card] = []
  @State private var isCardPickerPresented = false

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    NavigationStack {
      Form {
        DatePicker("Created at", selection: $createdAt, displayedComponents: .date)
        TextField("Optional name", text: $name)

        Section {
          ForEach(cards) { card in
            SmallCardRow(card: card)
          }
          Button {
            cardPickerSelection = []
            isCardPickerPresented = true
          } label: {
            Label("Add Cards", systemImage: "plus.app")
          }
        } header: {
          // TODO: 0 cards, 1 card, 1+ cards
          Text("\(cards.count) cards")
        }
      }.toolbar {
        ToolbarItem(placement: .principal) {
          Text(editorTitle)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            withAnimation {
              save()
              dismiss()
            }
          }.disabled($cards.wrappedValue.isEmpty)
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
      }
      .sheet(
        isPresented: $isCardPickerPresented,
        onDismiss: {
          cards.append(contentsOf: $cardPickerSelection.wrappedValue)
        }
      ) {
        CardPickerView(cube: cube, selection: $cardPickerSelection)
      }
      .onAppear {
        if let deck {
          createdAt = deck.createdAt
          name = deck.name
          cards = deck.cards
        }
      }
    }
  }

  private func save() {
    if let deck {
      // Edit the deck.
      deck.name = name
      deck.createdAt = createdAt
      deck.cards = cards
    } else {
      // Add new deck.
      let newDeck = Deck(cube: cube, createdAt: createdAt, name: name)
      modelContext.insert(newDeck)
      newDeck.cards = cards
    }
  }
}

#Preview("Add deck") {
  ModelContainerPreview(ModelContainer.sample) {
    DeckEditor(
      cube: Cube(id: "", shortId: "", name: ""), deck: nil)
  }
}

#Preview("Edit deck") {
  ModelContainerPreview(ModelContainer.sample) {
    DeckEditor(
      cube: Cube(id: "", shortId: "", name: ""),
      deck: Deck(cube: Cube(id: "", shortId: "", name: ""))
    )
  }
}
