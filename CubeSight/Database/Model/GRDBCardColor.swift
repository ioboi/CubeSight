import Foundation
import GRDB

struct GRDBCardColor: Codable, FetchableRecord, PersistableRecord {
  var cardId: UUID
  var color: ScryfallColor

  var cards: QueryInterfaceRequest<GRDBCard> {
    request(for: GRDBCardColor.cards)
  }

  enum Columns {
    static let cardId = Column(CodingKeys.cardId)
    static let color = Column(CodingKeys.color)
  }
}

extension GRDBCardColor: TableRecord {
  static var databaseTableName: String = "cardColor"

  static let cards = hasMany(GRDBCard.self)
}
