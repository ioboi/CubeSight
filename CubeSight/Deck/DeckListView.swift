import SwiftUI
import SwiftData

struct DeckListView: View {
  let cube: Cube

  @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
  @State private var isEditorPresented = false
  @Environment(\.modelContext) private var modelContext

  init(cube: Cube) {
    self.cube = cube
    let cubeId = cube.id
    let predicate = #Predicate<Deck> { deck in
      deck.cube.id == cubeId
    }
    _decks = Query(filter: predicate, sort: \Deck.createdAt, order: .reverse)
  }

  var body: some View {
    List {
      ForEach(decks) { deck in
        NavigationLink(destination: DeckDetailView(deck: deck)) {
          DeckRow(deck: deck)
        }
      }
      .onDelete(perform: removeDeck)
    }
    .fullScreenCover(isPresented: $isEditorPresented) {
      DeckScanner()
      //DeckEditor(cube: cube, deck: nil)
    }
    .overlay {
      if decks.isEmpty {
        ContentUnavailableView {
          Label("No decks available for this cube", systemImage: "dice")
        } description: {
          AddDeckButton(isActive: $isEditorPresented)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        AddDeckButton(isActive: $isEditorPresented)
      }
    }
  }

  private func removeDeck(at indexSet: IndexSet) {
    for index in indexSet {
      let deckToDelete = decks[index]
      modelContext.delete(deckToDelete)
    }
  }
}

private struct DeckRow: View {
  let deck: Deck
  var body: some View {
    HStack {
      Text("\(deck.createdAt, style: .date)")
      Spacer()
      Text(deck.name)
    }
  }
}

private struct AddDeckButton: View {
  @Binding var isActive: Bool
  var body: some View {
    Button {
      isActive = true
    } label: {
      Label("Add a deck", systemImage: "plus")
        .help("Add a deck")
    }
  }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
  DeckListView(cube: Cube.sampleCube)
}
