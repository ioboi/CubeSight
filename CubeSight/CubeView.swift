import SwiftData
import SwiftUI

struct CubeView: View {

  @State private var cubeId: String
  @State private var searchText: String

  init(cube: Cube) {
    cubeId = cube.id
    searchText = ""
  }

  var body: some View {
    CardList(cubeId: cubeId, searchText: searchText)
      .searchable(text: $searchText)
  }
}

#Preview {
  CubeView(cube: Cube(id: "", shortId: "", name: "Sample Cube"))
}
