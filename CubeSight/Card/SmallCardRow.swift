import SwiftUI

struct SmallCardRow: View {

  let card: Card

  var body: some View {
    HStack {
      if let image = card.image {
        Image(uiImage: UIImage(data: image)!)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 88)
          .clipShape(RoundedRectangle(cornerRadius: 2))
      } else {
        AsyncImage(url: URL(string: card.imageNormal)!) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 2))
        } placeholder: {
          ProgressView()
            .frame(height: 88)
        }
      }
      Text(card.name)
    }
  }
}

#Preview {
  List {
    SmallCardRow(card: Card.blackLotus)
  }
}
