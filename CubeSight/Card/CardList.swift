import SwiftData
import SwiftUI

struct CardList: View {

  @Query private var cards: [Card]

  init(cubeId: String, searchText: String = "") {
    let predicate = #Predicate<Card> { card in
      (searchText.isEmpty || card.name.localizedStandardContains(searchText))
        && card.mainboards.filter { $0.id == cubeId }.count == 1
    }
    _cards = Query(filter: predicate, sort: \.sortColorRawValue)
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

#Preview {
  CardList(cubeId: "")
}
