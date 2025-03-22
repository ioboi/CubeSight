import SwiftData
import SwiftUI

struct CardsSearchResults<Content: View>: View {
  @Binding var searchText: String
  private let cube: Cube
  @Query private var cards: [Card]
  private var content: (Card) -> Content

  init(
    cube: Cube,
    searchText: Binding<String>,
    @ViewBuilder content: @escaping (Card) -> Content
  ) {
    _searchText = searchText
    _cards = Query(
      filter: Card.predicate(
        cubeId: cube.id,
        searchText: searchText.wrappedValue
      ),
      sort: [SortDescriptor(\.rawColorcategory), SortDescriptor(\.manaValue)]
    )
    self.cube = cube
    self.content = content
  }

  var body: some View {
    ForEach(cards, content: content)
  }
}
