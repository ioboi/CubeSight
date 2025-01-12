import SwiftData
import SwiftUI

struct CardList: View {

  @Query private var cards: [Card]

  init(cubeId: String, searchText: String = "") {
    _cards = Query(
      filter: Card.predicate(cubeId: cubeId, searchText: searchText),
      sort: [SortDescriptor(\.rawColorcategory), SortDescriptor(\.manaValue)])
  }

  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 10) {
        ForEach(cards) { card in
          CardRow(card: card)
            .padding(.horizontal)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .safeAreaPadding(.vertical, 20)
  }
}

#Preview(traits: .sampleData) {
  CardList(cubeId: Cube.sampleCube.id)
}
