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
          /*card.localImageNormalUrl = try await self.downloadImage(
            prefix: "normal",
            url: card.imageNormalUrl
          )*/
          try await card.downloadImages()
        } catch {
          // TODO: Log the error
          //logger.error("Failed to download cube: \(error)")
        }
      }

      cube.mainboard = cards

      modelContext.insert(cube)
      try? modelContext.save()
      dismiss()
    }
    .navigationTitle("Import Cube")
  }

  private func downloadImage(url: String, to: URL) async throws {
    guard let urlToDownload = URL(string: url) else { return }
    let (downloadUrl, _) = try await URLSession.shared.download(
      from: urlToDownload
    )

    try FileManager.default.moveItem(at: downloadUrl, to: to)
  }
}

#Preview(traits: .sampleData) {
  NavigationStack {
    ImportCubeView(shortId: "dimlas3")
  }
}
