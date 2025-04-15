import SwiftData
import SwiftUI

struct CardsSearchResults: View {
  private let cube: Cube
  @Binding var searchText: String
  @Query private var cards: [Card]
  
  init(cube: Cube, searchText: Binding<String>) {
    self.cube = cube
    _searchText = searchText
    _cards = Query(
      filter: Card.predicate(cubeId: cube.id, searchText: searchText.wrappedValue),
      sort: [SortDescriptor(\.rawColorcategory), SortDescriptor(\.manaValue)])
  }
  
  var body: some View {
    ForEach(cards) { card in
      CardRow(card: card)
        .padding(.horizontal)
    }
  }
}
