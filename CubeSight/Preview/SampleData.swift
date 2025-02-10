import SwiftData
import SwiftUI

struct SampleData: PreviewModifier {

  static func makeSharedContext() async throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for:
        Card.self,
      Cube.self,
      CubeDeckCard.self,
      CubeDeck.self,
      Tournament.self,
      Player.self,
      Round.self,
      Match.self,
      configurations: config
    )
    Cube.makeSampleCube(in: container)
    CubeDeck.makeSampleCubeDecks(in: container)
    return container
  }

  func body(content: Content, context: ModelContainer) -> some View {
    content.modelContainer(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  @MainActor static var sampleData: Self = .modifier(SampleData())
}
