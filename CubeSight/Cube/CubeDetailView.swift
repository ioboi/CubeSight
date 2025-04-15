import SwiftData
import SwiftUI

enum CubeDetail: Codable, Hashable, Identifiable {
  case allCards
  
  var id: CubeDetail { self }
  
  var name: String {
    switch self {
    case .allCards:
      String(localized: "All", comment: "CubeDetail show all cards")
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
    }
  }
}

struct CubeDetailView: View {
  private let cube: Cube
  
  init(cube: Cube) {
    self.cube = cube
  }
  
  @ViewBuilder
  var cubeBanner: some View {
    if let imageData = cube.image {
      Image(uiImage: UIImage(data: imageData)!)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .listRowInsets(EdgeInsets())
    }
  }
  
  var body: some View {
    List {
      cubeBanner
      Section("Cards") {
        CubeDetail.allCards.view
      }
    }
    .navigationDestination(for: CubeDetail.self) { detail in
      detail.destination(with: cube)
    }
  }
}


#Preview(traits: .sampleData) {
  CubeDetailView(cube: Cube.sampleCube)
}
