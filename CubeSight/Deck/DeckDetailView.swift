import SwiftData
import SwiftUI

struct DeckDetailView: View {
  var deck: Deck
  var body: some View {
    // TODO: Implement edit
    // TODO: Show basic info of deck
    // TODO: Show graph (Mana curve? Colors?)
    List {
      ForEach(deck.cards) { card in
        SmallCardRow(card: card)
      }
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.sample) {
    DeckDetailView(deck: Deck.sampleDeck)
  }
}
