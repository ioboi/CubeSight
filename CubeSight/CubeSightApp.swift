import SwiftData
import SwiftUI

@main
struct CubeSightApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Card.self,
      Cube.self,
      CubeDeckCard.self,
      CubeDeck.self,
      DeckArchetype.self,
      Tournament.self,
      TournamentRound.self,
      TournamentPlayer.self,
      Player.self,
      TournamentMatch.self,
    ])
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )

    do {
      return try ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
      )
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          seedInitialData()
        }
    }
    .modelContainer(sharedModelContainer)
  }

  private func seedInitialData() {
    guard
      let count = try? sharedModelContainer.mainContext.fetchCount(
        FetchDescriptor<DeckArchetype>()
      ), count == 0
    else { return }

    // Insert default archetypes
    DeckArchetype.makeSampleCubeDeckArchetypes(in: sharedModelContainer)
    try? sharedModelContainer.mainContext.save()
  }
}
