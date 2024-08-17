import SwiftData
import SwiftUI

struct CubeView: View {

  let cube: Cube

  @State private var searchText: String = ""

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
      NavigationLink(
        destination: DeckListView(cube: cube)
          .navigationTitle("Decks")
      ) {
        Text("Decks")
          .badge(cube.decks.count)
      }
    }
  }
}

#Preview(traits: .sampleData) {
  CubeView(cube: Cube.sampleCube)
}
