import Foundation
import GRDB

extension AppDatabase {
  static let shared = makeShared()
  private static func makeShared() -> AppDatabase {
    do {
      let fileManager = FileManager.default
      let appSupportURL = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      let directoryURL = appSupportURL.appendingPathComponent(
        "Database",
        isDirectory: true
      )
      try fileManager.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true
      )

      let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
      let config = AppDatabase.makeConfiguration()
      let dbPool = try DatabasePool(
        path: databaseURL.path,
        configuration: config
      )

      let appDatabase = try AppDatabase(dbPool)
      return appDatabase
    } catch {
      fatalError("Unresolved error \(error)")
    }
  }

  /// Creates an empty database for SwiftUI previews
  static func empty() -> AppDatabase {
    // Connect to an in-memory database
    // See https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/databaseconnections
    let dbQueue = try! DatabaseQueue(
      configuration: AppDatabase.makeConfiguration()
    )
    return try! AppDatabase(dbQueue)
  }
}
