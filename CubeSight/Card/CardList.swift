import SwiftData
import SwiftUI

struct CardList: View {
  let cube: Cube
  
  @State private var searchText: String = ""
  
  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 10) {
        CardsSearchResults(cube: cube, searchText: $searchText) { card in
          CardGridItem(card: card)
        }
      }
      .scrollTargetLayout()
      .padding()
    }
    .scrollTargetBehavior(.viewAligned)
    .safeAreaPadding(.vertical, 20)
    .searchable(text: $searchText)
  }
}

#Preview(traits: .sampleData) {
  CardList(cube: Cube.sampleCube)
}
