import SwiftData
import SwiftUI

struct CubeDetailView: View {
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
          destination: CardList(cube: cube)
            .navigationTitle("All")
        ) {
          Text("All")
            .badge(cube.mainboard.count)
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  CubeDetailView(cube: Cube.sampleCube)
}
