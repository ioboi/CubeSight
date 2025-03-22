import SwiftUI

struct CardArtCropRow: View {
  let card: Card
  var body: some View {
    HStack {
      AsyncImage(url: card.artCropUrl) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      } placeholder: {
        ProgressView()
      }
      .frame(height: 44)
      Text(card.name)
    }
  }
}

#Preview(traits: .sampleData) {
  List {
    CardArtCropRow(card: .blackLotus)
  }
}
