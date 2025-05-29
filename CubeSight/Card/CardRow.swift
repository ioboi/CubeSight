import SwiftUI

struct CardRow: View {
  let card: Card
  var body: some View {
    VStack {
      AsyncImage(
        url: card.imageNormalUrl
      ) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 20))
      } placeholder: {
        ProgressView {
          Text(card.name)
        }
      }
    }
  }
}

#Preview {
  CardRow(card: Card.blackLotus)
    .padding()
}
