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
  CardRow(card: Card.blackLotus)
    .padding()
}
