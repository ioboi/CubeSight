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
      Tournament.self,
      TournamentRound.self,
      TournamentPlayer.self,
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
    }
    .modelContainer(sharedModelContainer)
  }
}
