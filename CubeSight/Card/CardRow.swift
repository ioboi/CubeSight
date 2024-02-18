import SwiftUI

struct CardRow: View {

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
  CardRow(
    card: Card(
      id: UUID(), name: "XYZ", imageSmall: "",
      imageNormal:
        "https://cards.scryfall.io/normal/front/a/2/a24e8dba-5c86-4e32-8a52-61402f7fe9f0.jpg?1594734854",
      colors: [.black])
  )
  .padding()
}
