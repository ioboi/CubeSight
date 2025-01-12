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
  static func from(_ cardColor: CubeCobraClient.Card.Details.CardColor) -> CardColor {
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
  static func from(_ colorCateogry: CubeCobraClient.Card.Details.Colorcategory) -> Colorcategory {
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
  var imageSmall: String
  var imageNormal: String
  @Attribute(.externalStorage) var image: Data?
  var colors: [CardColor]
  var manaValue: Int
  var rawColorcategory: String

  @Relationship(inverse: \Cube.mainboard) var mainboards: [Cube] = []

  init(
    id: UUID, name: String, imageSmall: String, imageNormal: String, colors: [CardColor],
    manaValue: Int,
    colorcategory: Colorcategory
  ) {
    self.id = id
    self.name = name
    self.imageSmall = imageSmall
    self.imageNormal = imageNormal
    self.colors = colors
    self.manaValue = manaValue
    self.rawColorcategory = colorcategory.rawValue
  }
}

extension Card {
  convenience init(_ from: CubeCobraClient.Card) {

    self.init(
      id: from.cardId, name: from.details.name, imageSmall: from.details.imageSmall,
      imageNormal: from.details.imageNormal,
      colors: from.details.colors.map({ c in CardColor.from(c) }),
      manaValue: from.details.cmc,
      colorcategory: Colorcategory.from(from.details.colorcategory))
  }

  static func predicate(cubeId: String, searchText: String) -> Predicate<Card> {
    return #Predicate<Card> { card in
      (searchText.isEmpty || card.name.localizedStandardContains(searchText))
        && card.mainboards.filter { $0.id == cubeId }.count == 1
    }
  }
}

extension Card {
  @MainActor static let blackLotus = Card(
    id: UUID(uuidString: "bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd")!,
    name: "Black Lotus",
    imageSmall:
      "https://cards.scryfall.io/small/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838",
    imageNormal:
      "https://cards.scryfall.io/normal/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838",
    colors: [],
    manaValue: 0,
    colorcategory: .colorless
  )
}
