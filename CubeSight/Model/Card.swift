import Foundation
import SwiftData

enum CardColor: String, Codable {
  case blue = "blue"
  case green = "green"
  case red = "red"
  case white = "white"
  case black = "black"
}

extension CardColor {
  static func from(_ cardColor: CubeCobraClient.Card.Details.CardColor)
    -> CardColor
  {
    switch cardColor {
    case .blue:
      CardColor.blue
    case .green:
      CardColor.green
    case .red:
      CardColor.red
    case .white:
      CardColor.white
    case .black:
      CardColor.black
    }
  }
}

enum Colorcategory: String, Codable {
  case blue = "u"
  case green = "g"
  case red = "r"
  case white = "w"
  case black = "b"
  case colorless = "c"
  case multicolored = "m"
  case land = "l"
}

extension Colorcategory {
  static func from(_ colorCateogry: CubeCobraClient.Card.Details.Colorcategory)
    -> Colorcategory
  {
    switch colorCateogry {
    case .blue:
      .blue
    case .green:
      .green
    case .red:
      .red
    case .white:
      .white
    case .black:
      .black
    case .colorless:
      .colorless
    case .multicolored:
      .multicolored
    case .land:
      .land
    }
  }
}

@Model class Card {
  @Attribute(.unique) var id: UUID
  var name: String
  var imageNormal: String
  var artCrop: String
  var colors: [CardColor]
  var manaValue: Int
  var rawColorcategory: String

  var scryfallId: String

  @Relationship(inverse: \Cube.mainboard) var mainboards: [Cube] = []

  init(
    id: UUID,
    name: String,
    imageNormalUrl: String,
    artCropUrl: String,
    colors: [CardColor],
    manaValue: Int,
    colorcategory: Colorcategory,
    scryfallId: String
  ) {
    self.id = id
    self.name = name

    self.imageNormal = imageNormalUrl
    self.artCrop = artCropUrl

    self.colors = colors
    self.manaValue = manaValue
    self.rawColorcategory = colorcategory.rawValue
    self.scryfallId = scryfallId
  }
}

extension Card {
  convenience init(_ from: CubeCobraClient.Card) {
    self.init(
      id: from.cardId,
      name: from.details.name,
      imageNormalUrl: from.details.imageNormal,
      artCropUrl: from.details.artCrop,
      colors: from.details.colors.map({ c in CardColor.from(c) }),
      manaValue: from.details.cmc,
      colorcategory: Colorcategory.from(from.details.colorcategory),
      scryfallId: from.details.scryfallId
    )
  }

  static func predicate(cubeId: String, searchText: String) -> Predicate<Card> {
    return #Predicate<Card> { card in
      card.mainboards.filter { $0.id == cubeId }.count == 1
        && (searchText.isEmpty
          || card.name.localizedStandardContains(searchText))
    }
  }
}

extension Card {
  @MainActor static let blackLotus = Card(
    id: UUID(uuidString: "bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd")!,
    name: "Black Lotus",
    imageNormalUrl:
      "https://cards.scryfall.io/normal/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838",
    artCropUrl:
      "https://cards.scryfall.io/art_crop/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838",
    colors: [],
    manaValue: 0,
    colorcategory: .colorless,
    scryfallId: "bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd"
  )
}

extension Card {
  private var imageNormalName: String {
    "normal_\(scryfallId).jpg"
  }

  private var artCropName: String {
    "crop_\(scryfallId).jpg"
  }

  var imageNormalUrl: URL? {
    guard
      let result = FileManager.default.documentDirectory?.appending(
        path: imageNormalName
      ),
      FileManager.default.fileExists(atPath: result.path())
    else {
      return URL(string: imageNormal)
    }
    return result
  }

  var artCropUrl: URL? {
    guard
      let result = FileManager.default.documentDirectory?.appending(
        path: artCropName
      ),
      FileManager.default.fileExists(atPath: result.path())
    else {
      return URL(string: artCrop)
    }
    return result
  }

  func downloadImages() async throws {
    guard let normalImageUrl = URL(string: self.imageNormal),
      let artCropUrl = URL(string: self.artCrop)
    else {
      return
    }

    guard let documentDirectory = FileManager.default.documentDirectory else {
      return
    }

    let (downloadNormalImage, _) = try await URLSession.shared.download(
      from: normalImageUrl
    )
    try FileManager.default.moveItem(
      at: downloadNormalImage,
      to: documentDirectory.appendingPathComponent(
        imageNormalName
      )
    )

    let (downloadArtCrop, _) = try await URLSession.shared.download(
      from: artCropUrl
    )
    try FileManager.default.moveItem(
      at: downloadArtCrop,
      to: documentDirectory.appendingPathComponent(
        artCropName
      )
    )
  }
}
