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
            LazyVStack(spacing: 10) {
                ForEach(cards) { card in
                    CardView(card: card)
                        .padding(.horizontal)
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
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                AsyncImage(url: URL(string: card.imageNormal)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    CardView(card: Card(id: UUID(), name: "XYZ", imageSmall: "", imageNormal: "https://cards.scryfall.io/normal/front/a/2/a24e8dba-5c86-4e32-8a52-61402f7fe9f0.jpg?1594734854", colors: [.black]))
        .padding()
}

#Preview {
    CubeView(cube: Cube(id: "", shortId: "", name: "Sample Cube"))
}
