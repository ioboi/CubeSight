import Foundation
import GRDB

extension DerivableRequest<GRDBCard> {
  func filter(colors: [ScryfallColor]) -> Self {
    self.joining(
      required: GRDBCard.colors.filter { colors.contains($0.color) }
    )
    .distinct()
  }
}
