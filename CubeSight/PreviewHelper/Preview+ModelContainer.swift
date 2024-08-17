import Foundation
import SwiftData

extension ModelContainer {
  static var sample: () throws -> ModelContainer = {
    let schema = Schema([Card.self, Cube.self, Deck.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    Task { @MainActor in
      Cube.insertSampleData(modelContext: container.mainContext)
    }
    return container
  }
}
