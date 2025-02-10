import Foundation
import SwiftData

extension ModelContainer {
  @MainActor static var sample: () throws -> ModelContainer = {
    let schema = Schema([Card.self, Cube.self, Deck.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    Task { @MainActor in
      Cube.makeSampleCube(in: container)
    }
    return container
  }
}
