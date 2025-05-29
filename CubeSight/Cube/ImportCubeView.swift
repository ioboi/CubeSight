import SwiftUI

struct ImportCubeView: View {

  var shortId: String

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ProgressView {
      Text("Import cube with cube ID \"\(shortId)\"")
    }.task {
      let client = CubeCobraClient()
      guard let result = await client.cube(shortId: shortId) else {
        return
      }
      let cube = Cube(id: result.id, shortId: result.shortId, name: result.name)

      if let coverImage = result.image {
        do {
          guard let url = URL(string: coverImage.uri) else { return }
          let request = URLRequest(url: url)
          let (data, _) = try await URLSession.shared.data(for: request)
          cube.image = data
        } catch {
          // TODO
          //logger.error("Failed to download cube: \(error)")
        }
      }

      let cards = result.cards.mainboard.map { card in
        Card(card)
      }

      for card in cards {
        do {
          guard let url = URL(string: card.imageNormal) else { return }
          let (data, _) = try await URLSession.shared.data(from: url)
          card.image = data

          guard let url = URL(string: card.artCropUrl) else { return }
          let (artCropData, _) = try await URLSession.shared.data(from: url)
          card.artCrop = artCropData
        } catch {
          // TODO
          //logger.error("Failed to download cube: \(error)")
        }
      }

      cube.mainboard = cards

      modelContext.insert(cube)
      dismiss()
    }
    .navigationTitle("Import Cube")
  }
}

#Preview(traits: .sampleData) {
  NavigationStack {
    ImportCubeView(shortId: "dimlas3")
  }
}
