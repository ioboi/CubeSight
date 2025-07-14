import Foundation
import SwiftData

@Model class CubeDeck {
  var id: UUID
  @Attribute var createdAt: Date
  @Attribute var name: String

  // TODO: Check if we want to make it optional?
  var decktype: String = ""
  var archetype: DeckArchetype?
  var cube: Cube
  var cards: [CubeDeckCard] = []
  @Relationship(inverse: \TournamentPlayer.draftedDeck) var tournamentPlayer:
    TournamentPlayer?

  init(
    cube: Cube,
    name: String = "",
    createdAt: Date = Date(),
    archetype: DeckArchetype? = nil
  ) {
    self.id = UUID()
    self.cube = cube
    self.name = name
    self.createdAt = Calendar.current.startOfDay(for: createdAt)
  }
}

extension CubeDeck {
  @MainActor static var previewCubeDecks: [CubeDeck] = [
    CubeDeck(
      cube: Cube.sampleCube,
      name: "Sample Aggro Deck",
      archetype: DeckArchetype.aggro
    ),
    CubeDeck(cube: Cube.sampleCube),
  ]

  @MainActor static var previewCubeDeckCards: [CubeDeckCard] = [
    CubeDeckCard(deck: previewCubeDecks[0], card: Card.blackLotus)
  ]

  @MainActor static func makeSampleCubeDecks(in context: ModelContainer) {
    for cubeDeck in previewCubeDecks {
      context.mainContext.insert(cubeDeck)
    }
    for card in previewCubeDeckCards {
      context.mainContext.insert(card)
    }
  }
}
