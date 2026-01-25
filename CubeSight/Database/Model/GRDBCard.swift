import Foundation
import GRDB

struct GRDBCard: Codable, Identifiable, FetchableRecord, PersistableRecord {
  var id: UUID  // Scryfall ID

  // MARK: - Gameplay Fields
  var name: String
  var cmc: Double
  var colors: QueryInterfaceRequest<GRDBCardColor> {
    request(for: GRDBCard.colors)
  }

  // MARK: - Print Fields
  var borderCropUrl: URL
  var artCropUrl: URL

  enum Columns {
    static let name = Column(CodingKeys.name)
    static let cmc = Column(CodingKeys.cmc)
    //static let colors = Column(CodingKeys.colors)
    static let borderCropUrl = Column(CodingKeys.borderCropUrl)
  }
}

extension GRDBCard: TableRecord {
  static var databaseTableName: String = "card"

  static let colors = hasMany(GRDBCardColor.self)
}

extension GRDBCard {
  static let sampleBlackLotus = GRDBCard(
    id: UUID(uuidString: "bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd")!,
    name: "Black Lotus",
    cmc: 0.0,
    borderCropUrl: URL(
      string:
        "https://cards.scryfall.io/border_crop/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838"
    )!,
    artCropUrl: URL(
      string:
        "https://cards.scryfall.io/art_crop/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1614638838"
    )!
  )

  static func makeCards(in database: any DatabaseWriter) {
    try! database.write { db in
      _ = try GRDBCard.sampleBlackLotus.insert(db)
    }
  }
}
