import SwiftUI

struct CubeDeckRow: View {
  let cubeDeck: CubeDeck
  
  var body: some View {
    NavigationLink(value: cubeDeck) {
      VStack(alignment: .leading) {
        if cubeDeck.name != "" {
          Text(cubeDeck.name)
        } else {
          Text("Unnamed")
        }
        Text(cubeDeck.createdAt, style: .date)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

#Preview {
  List {
    CubeDeckRow(cubeDeck: CubeDeck.previewCubeDecks[0])
    CubeDeckRow(cubeDeck: CubeDeck.previewCubeDecks[1])
  }
}
