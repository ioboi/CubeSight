import Foundation
import GRDB
import Testing

@testable import CubeSight

struct CardColorTests {

  struct CardColorFilterTestCase: CustomTestStringConvertible {
    let colors: [ScryfallColor]
    let expectedCount: Int

    var testDescription: String {
      "filtering for colors: \(colors.map(\.rawValue)), expected count: \(expectedCount)"
    }
  }

  @Test(arguments: [
    CardColorFilterTestCase(colors: [.black], expectedCount: 1),
    CardColorFilterTestCase(colors: [.blue], expectedCount: 1),
    CardColorFilterTestCase(colors: [.black, .blue], expectedCount: 1),
    CardColorFilterTestCase(colors: [.green], expectedCount: 0),
    CardColorFilterTestCase(colors: [.red, .green], expectedCount: 0),
  ]) func filterForCardColors(tc: CardColorFilterTestCase) async throws {
    let db = try await makeAppDatabase()

    let count = try await db.reader.read { db in
      try GRDBCard.joining(
        required: GRDBCard.colors.filter { tc.colors.contains($0.color) }
      )
      .distinct()
      .fetchCount(db)
    }
    #expect(count == tc.expectedCount)
  }

  func makeAppDatabase() async throws -> AppDatabase {
    let db = AppDatabase.empty()
    try await db.writer.write { db in
      let url = URL(
        string:
          "https://cards.scryfall.io/border_crop/front/0/8/08b8afa9-9e9d-4552-8709-4ba4af79ead3.jpg?1739794513"
      )!
      let card = GRDBCard(
        id: UUID(),
        name: "Test",
        cmc: 1.0,
        borderCropUrl: url,
        artCropUrl: url
      )
      let colors = [
        GRDBCardColor(cardId: card.id, color: .black),
        GRDBCardColor(cardId: card.id, color: .blue),
      ]

      try card.insert(db)
      try colors.forEach { try $0.insert(db) }
    }
    return db
  }
}
