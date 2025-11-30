import Foundation
import GRDBQuery
import SwiftUI

struct GRDBSampleData: PreviewModifier {
  static func makeSharedContext() async throws -> AppDatabase {
    let appDatabase = AppDatabase.empty()

    let writer = appDatabase.writer

    GRDBCard.makeCards(in: writer)

    return appDatabase
  }

  func body(content: Content, context: AppDatabase) -> some View {
    content.databaseContext(
      .readWrite({
        context.writer
      })
    )
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  @MainActor static var grdbSampleData: Self = .modifier(SampleData())
}
