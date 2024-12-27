import SwiftData
import SwiftUI

struct CubeView: View {

  @State private var searchText: String = ""

  private let cube: Cube

  init(cube: Cube) {
    self.cube = cube
  }

  var body: some View {
    List {
      if let imageData = cube.image {
        Section {
          Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .listRowInsets(EdgeInsets())
        }
      }
      Section("Cards") {
        NavigationLink(
          destination: CardList(cubeId: cube.id, searchText: searchText).searchable(
            text: $searchText
          ).navigationTitle("All")
        ) {
          Text("All")
            .badge(cube.mainboard.count)
        }
      }

      NavigationLink(destination: DeckListView(cube: cube)) {
        Text("Decks")
      }
    }
  }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
  CubeView(cube: Cube.sampleCube)
}
