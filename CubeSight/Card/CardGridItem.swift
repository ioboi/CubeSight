import SwiftUI

struct CardGridItem: View {
  let card: Card

  var body: some View {
    AsyncImage(url: card.imageNormalUrl) { image in
      image
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 10))
    } placeholder: {
      VStack {
        ProgressView()
        Text(card.name)
      } 
    }
  }
}

#Preview {
  CardGridItem(card: Card.blackLotus)
}
