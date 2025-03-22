import SwiftUI
import SwiftData

struct CubeDeckListView: View {
  let cube: Cube
  
  var body: some View {
    CubeDeckList(cube: cube)
  }
}

private struct CubeDeckList: View {
  let cube: Cube
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \CubeDeck.createdAt, order: .reverse) private var decks: [CubeDeck]
  @State private var isCubeDeckEditorPresented: Bool = false
  
  init(cube: Cube) {
    self.cube = cube
    let id = cube.id
    let predicate = #Predicate<CubeDeck> { deck in
      deck.cube.id == id
    }
    _decks = Query(filter: predicate, sort: \.createdAt, order: .reverse)
  }
  
  var body: some View {
    List {
      ForEach(cube.decks.sorted(by: { $0.createdAt < $1.createdAt})) { cubeDeck in
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
