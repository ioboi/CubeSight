import Foundation
import GRDB
import OSLog

struct AppDatabase: Sendable {
  let writer: any DatabaseWriter
  var reader: any GRDB.DatabaseReader { writer }

  init(_ writer: any DatabaseWriter) throws {
    self.writer = writer
    try migrator.migrate(writer)
  }

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    #if DEBUG
      migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("v1") { db in
      try db.create(table: "card") { t in
        t.primaryKey("id", .text)
        t.column("name", .text).notNull()
        t.column("cmc", .double).notNull()
        t.column("borderCropUrl", .text).notNull()  // TODO: Check if this is true
        t.column("artCropUrl", .text).notNull()  // TODO: Check if this is true
      }

      try db.create(table: "cardColor") { t in
        t.primaryKey {
          t.belongsTo("card", onDelete: .cascade)
          t.column("color", .text)
        }
      }
    }

    return migrator
  }
}

extension AppDatabase {
  private static let sqlLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "SQL"
  )

  static func makeConfiguration(_ config: Configuration = Configuration())
    -> Configuration
  {
    var config = config

    if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
      config.prepareDatabase { db in
        let dbName = db.description
        db.trace { event in
          // Sensitive information (statement arguments) is not
          // logged unless config.publicStatementArguments is set
          // (see below).
          sqlLogger.debug("\(dbName): \(event)")
        }
      }
    }

    #if DEBUG
      config.publicStatementArguments = true
    #endif

    return config
  }
}
