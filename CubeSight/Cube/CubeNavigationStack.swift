import SwiftData
import SwiftUI

struct CubeNavigationStack: View {
  @Query var cubes: [Cube]
  @State private var importing = false
  @State private var selection: Cube? = nil
  
  @ViewBuilder
  var contentUnavailableView: some View {
    ContentUnavailableView {
      Text("No Cubes 😭")
    } description: {
      Text("Import cubes from Cube Cobra.")
    } actions: {
      Button(action: { importing = true }) {
        Label("Import \"Vintage Cube Season 4\"", systemImage: "square.and.arrow.down")
      }
    }
  }
  
  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        ForEach(cubes) { cube in
          NavigationLink(cube.name, value: cube)
        }
      }
      .sheet(isPresented: $importing) {
        NavigationStack {
          ImportCubeView(shortId: "dimlas4")
        }.interactiveDismissDisabled()
      }
      .overlay {
        if cubes.isEmpty {
          contentUnavailableView
        }
      }
      .navigationTitle("Cubes")
    } detail: {
      if let cube = selection {
        NavigationStack {
          CubeDetailView(cube: cube)
            .navigationTitle(cube.name)
        }
      } else {
        if !cubes.isEmpty {
          Text("Select a cube")
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  CubeNavigationStack()
}
