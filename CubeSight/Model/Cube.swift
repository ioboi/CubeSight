import Foundation
import SwiftData

@Model class Cube {
  @Attribute(.unique) var id: String
  @Attribute(.unique) var shortId: String
  var name: String

  var image: String?
  var imageUrl: URL? {
    guard
      let result = FileManager.default.documentDirectory?.appending(
        path: "\(self.id).jpg"
      ),
      FileManager.default.fileExists(atPath: result.path())
    else {
      if let image {
        return URL(string: image)
      }
      return nil
    }
    return result
  }
  @Relationship(deleteRule: .cascade, inverse: \CubeDeck.cube) var decks:
    [CubeDeck] = []

  var mainboard: [Card] = []

  init(id: String, shortId: String, name: String, image: String? = nil) {
    self.id = id
    self.shortId = shortId
    self.name = name
    self.image = image
  }
}

extension Cube {
  func downloadImage() async throws {
    guard let image = self.image,
      let imageUrl = URL(string: image),
      let documentDirectory = FileManager.default.documentDirectory
    else {
      return
    }

    let (downloadedImage, _) = try await URLSession.shared.download(
      from: imageUrl
    )
    try FileManager.default.moveItem(
      at: downloadedImage,
      to: documentDirectory.appendingPathComponent("\(self.id).jpg")
    )
  }

  @MainActor static let sampleCube = Cube(
    id: UUID().uuidString,
    shortId: "dimlas4",
    name: "Vintage Cube",
    image:
      "https://cards.scryfall.io/art_crop/front/b/c/bc0de77a-c503-4000-9eb5-aa28a5e91082.jpg?1690005636"
  )

  @MainActor
  static func makeSampleCube(in context: ModelContainer) {
    context.mainContext.insert(Card.blackLotus)
    sampleCube.mainboard = [Card.blackLotus]
    context.mainContext.insert(sampleCube)
  }
}
