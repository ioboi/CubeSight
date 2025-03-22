import SwiftUI

struct CubeDeckCardRow: View {
  @Bindable var cubeDeckCard: CubeDeckCard

  var artCrop: some View {
    AsyncImage(url: cubeDeckCard.card.artCropUrl) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    } placeholder: {
      ProgressView()
    }
  }

  var quantity: some View {
    Text("\(cubeDeckCard.quantity) \(Image(systemName: "multiply"))")
      .bold()
  }

  var stepper: some View {
    Stepper("Quantity", value: $cubeDeckCard.quantity, in: 1...Int.max)
      .labelsHidden()
  }

  var body: some View {
    HStack {
      artCrop
        .frame(height: 88)
      VStack(alignment: .leading) {
        HStack(alignment: .firstTextBaseline) {
          Text(cubeDeckCard.card.name)
          Spacer()
          quantity
        }
        HStack {
          Spacer()
          stepper
        }
      }.padding()
    }
  }
}

#Preview(traits: .sampleData) {
  List {
    CubeDeckCardRow(cubeDeckCard: CubeDeck.previewCubeDeckCards[0])
  }
}
