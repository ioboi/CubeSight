import Foundation
import SwiftData

enum CardColor: String, Codable {
  case blue = "blue"
  case green = "green"
  case red = "red"
  case white = "white"
  case black = "black"
  case multi = "multi"
  case none = "none"
}

@Model class Card {
  @Attribute(.unique) var id: UUID
  var name: String
  var imageSmall: String
  var imageNormal: String
  @Attribute(.externalStorage) var image: Data?
  var colors: [CardColor]
  var sortColorRawValue: String

  @Relationship(inverse: \Cube.mainboard) var mainboards: [Cube] = []

  init(id: UUID, name: String, imageSmall: String, imageNormal: String, colors: [CardColor]) {
    self.id = id
    self.name = name
    self.imageSmall = imageSmall
    self.imageNormal = imageNormal
    self.colors = colors

    self.sortColorRawValue = colors.first?.rawValue ?? CardColor.none.rawValue
    if colors.count > 1 {
      self.sortColorRawValue = CardColor.multi.rawValue
    }
  }
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

extension Card {
  convenience init(_ from: CubeCobraClient.Card) {

    self.init(
      id: from.cardId, name: from.details.name, imageSmall: from.details.imageSmall,
      imageNormal: from.details.imageNormal,
      colors: from.details.colors.map({ c in CardColor.from(c) }))
  }

  static func predicate(cubeId: String, searchText: String) -> Predicate<Card> {
    return #Predicate<Card> { card in
      (searchText.isEmpty || card.name.localizedStandardContains(searchText))
        && card.mainboards.filter { $0.id == cubeId }.count == 1
    }
  }
}
