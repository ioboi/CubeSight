import SwiftData
import SwiftUI

struct CubeView: View {

  @Query private var cards: [Card]

  init(cube: Cube) {
    let cubeId = cube.id
    let predicate = #Predicate<Card> { card in
      card.mainboards.filter { $0.id == cubeId }.count == 1
    }

    _cards = Query(filter: predicate, sort: \.sortColorRawValue)
  }

  var body: some View {
    ScrollView(.vertical) {
      LazyVStack {
        ForEach(cards) { card in
          CardView(card: card)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .safeAreaPadding(.vertical, 20)
  }
}

struct CardView: View {
  let card: Card
  var body: some View {
    VStack {
      if let image = card.image {
        Image(uiImage: UIImage(data: image)!).resizable().aspectRatio(contentMode: .fit)
      } else {
        AsyncImage(url: URL(string: card.imageNormal)!) { image in
          image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
          ProgressView()
        }
      }
    }
  }
}

#Preview {
  CubeView(cube: Cube(id: "", shortId: "", name: "Sample Cube"))
}
