import SwiftData
import SwiftUI

struct CubeDeckDetailView: View {
  var deck: CubeDeck

  private var navigationTitle: String {
    deck.name.isEmpty ? "Unnamed" : deck.name
  }

  var body: some View {
    CubeDeckCardGrid(deck: deck)
      .navigationTitle(navigationTitle)
  }
}

private struct CubeDeckCardGrid: View {
  let deck: CubeDeck
  @State private var isCubeDeckCardPickerPresented = false
  @State private var isCubeDeckEditorPresented: Bool = false
  @State private var importedCards: Set<Card> = []
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    List {
      ForEach(deck.cards) { cubeDeckCard in
        CubeDeckCardRow(cubeDeckCard: cubeDeckCard)
      }
      .onDelete(perform: removeCardFromDeck)
      Section {
        Button {
          isCubeDeckCardPickerPresented = true
        } label: {
          AddCardRow()
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Edit") { isCubeDeckEditorPresented = true }
      }
    }
    .sheet(
      isPresented: $isCubeDeckCardPickerPresented,
      onDismiss: addSelectedCardsToDeck
    ) {
      CardPicker(cube: deck.cube, selection: $importedCards)
    }
    .sheet(isPresented: $isCubeDeckEditorPresented) {
      CubeDeckEditor(cube: deck.cube, deck: deck)
    }
  }

  private func removeCardFromDeck(indexSet: IndexSet) {
    for index in indexSet {
      modelContext.delete(deck.cards.remove(at: index))
    }
  }

  private func addSelectedCardsToDeck() {
    withAnimation {
      for card in importedCards {
        // If deck already contains the card just adjust the quantity
        if let deckCard = deck.cards.first(where: { $0.card == card }) {
          deckCard.quantity += 1
          continue
        }

        let newDeckCard = CubeDeckCard(deck: deck, card: card)
        deck.cards.append(newDeckCard)
      }
      importedCards.removeAll()
    }
  }
}

#Preview(traits: .sampleData) {
  NavigationStack {
    CubeDeckDetailView(deck: CubeDeck.previewCubeDecks[0])
  }
}
