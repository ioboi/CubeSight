import SwiftData
import SwiftUI

struct ContentView: View {

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
              Label("Import \"Vintage Cube Season 3\"", systemImage: "square.and.arrow.down")
            }
          }
        }
      }
      .sheet(isPresented: $importing) {
        NavigationStack {
          ImportCubeView(shortId: "dimlas3")
        }.interactiveDismissDisabled()
      }
      .navigationTitle("Cubes")
    }
  }

}

#Preview {
  ContentView()
    .modelContainer(for: [Card.self, Cube.self], inMemory: true)
}
