import SwiftData
import SwiftUI

struct CubeContentView: View {

  @Query var cubes: [Cube]
  @State private var importing = false

  var body: some View {
    NavigationStack {
      List {
        NavigationLink(destination: TextRecognitionView()) {
          Label("Card Text Recognition", systemImage: "text.viewfinder")
        }
        ForEach(cubes) { cube in
          NavigationLink(cube.name, destination: CubeView(cube: cube).navigationTitle(cube.name))
        }
      }.overlay {
        if cubes.isEmpty {
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
      }
      .sheet(isPresented: $importing) {
        NavigationStack {
          ImportCubeView(shortId: "dimlas4")
        }.interactiveDismissDisabled()
      }
      .navigationTitle("Cubes")
    }
  }

}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
  CubeContentView()
}
