import SwiftData
import SwiftUI

struct CubeDeckListView: View {
  let cube: Cube

  var body: some View {
    CubeDeckList(cube: cube)
  }
}

private struct CubeDeckList: View {
  let cube: Cube
  @Environment(\.modelContext) private var modelContext
  @Query private var decks: [CubeDeck]
  @State private var isCubeDeckEditorPresented: Bool = false

  init(cube: Cube) {
    self.cube = cube
    let id = cube.persistentModelID
    let predicate = #Predicate<CubeDeck> { deck in
      deck.cube.persistentModelID == id
    }

    _decks = Query(
      filter: predicate,
      sort: [
        SortDescriptor(\CubeDeck.createdAt, order: .reverse),
        SortDescriptor(\CubeDeck.name),
      ]
    )
  }

  var body: some View {
    List {
      ForEach(decks) { cubeDeck in
        CubeDeckRow(cubeDeck: cubeDeck)
      }
      .onDelete(perform: removeDecks)
    }
    .sheet(isPresented: $isCubeDeckEditorPresented) {
      CubeDeckEditor(cube: cube, deck: nil)
    }
    .overlay {
      if decks.isEmpty {
        ContentUnavailableView {
          Label("No decks in this cube", systemImage: "square.3.stack.3d")
        } description: {
          AddDeckButton(isActive: $isCubeDeckEditorPresented)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        AddDeckButton(isActive: $isCubeDeckEditorPresented)
      }
    }
    .navigationDestination(for: CubeDeck.self) { cubeDeck in
      CubeDeckDetailView(deck: cubeDeck)
    }
  }

  private func removeDecks(at indexSet: IndexSet) {
    for index in indexSet {
      modelContext.delete(decks[index])
    }
    try? modelContext.save()
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

#Preview(traits: .sampleData) {
  NavigationStack {
    CubeDeckListView(cube: Cube.sampleCube)
  }
}
