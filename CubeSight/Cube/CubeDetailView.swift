import SwiftData
import SwiftUI

enum CubeDetail: Codable, Hashable, Identifiable {
  case allCards
  case decks

  var id: CubeDetail { self }

  var name: String {
    switch self {
    case .allCards:
      String(localized: "All", comment: "CubeDetail show all cards")
    case .decks:
      String(localized: "Decks", comment: "CubeDetail show all decks")
    }
  }

  @ViewBuilder
  var view: some View {
    NavigationLink(self.name, value: self)
  }

  @ViewBuilder
  func destination(with cube: Cube) -> some View {
    switch self {
    case .allCards:
      CardList(cube: cube)
        .navigationTitle("All Cards")
    case .decks:
      CubeDeckListView(cube: cube)
        .navigationTitle("Decks")
    }
  }
}

struct CubeDetailView: View {
  private let cube: Cube

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  init(cube: Cube) {
    self.cube = cube
  }

  var cubeImage: some View {
    AsyncImage(url: cube.imageUrl) { image in
      image
        .resizable()
        .scaledToFill()
    } placeholder: {
      ProgressView()
    }
    .frame(height: horizontalSizeClass == .compact ? 88 : 2 * 88)
    .listRowInsets(EdgeInsets())
  }

  var body: some View {
    List {
      if cube.image != nil {
        cubeImage
      }
      Section("Cards") {
        CubeDetail.allCards.view
      }
      CubeDetail.decks.view
    }
    .navigationDestination(for: CubeDetail.self) { detail in
      detail.destination(with: cube)
    }
  }
}

#Preview(traits: .sampleData) {
  CubeDetailView(cube: Cube.sampleCube)
}
