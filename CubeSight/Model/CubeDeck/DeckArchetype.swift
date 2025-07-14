import SwiftData

@Model class DeckArchetype {
  #Unique([\DeckArchetype.name])

  var name: String
  @Relationship(inverse: \CubeDeck.archetype) var cubeDecks: [CubeDeck] = []

  init(name: String) {
    self.name = name
  }
}

extension DeckArchetype {
  static let aggro: DeckArchetype = DeckArchetype(name: "Aggro")

  static let defaultArchetypes: [DeckArchetype] = [
    aggro,
    DeckArchetype(name: "Control"),
    DeckArchetype(name: "Combo"),
    DeckArchetype(name: "Aggro-Combo"),
    DeckArchetype(name: "Combo-Control"),
    DeckArchetype(name: "Control-Aggro (Midrange)"),
    DeckArchetype(name: "Aggro-Control (Tempo)"),
  ]

  @MainActor static func makeSampleCubeDeckArchetypes(
    in context: ModelContainer
  ) {
    for archetype in defaultArchetypes {
      context.mainContext.insert(archetype)
    }
  }
}
