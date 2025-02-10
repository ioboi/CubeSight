import Foundation
import SwiftData

@Model
class Player {
  var id: UUID
  var name: String

  init(name: String) {
    self.id = UUID()
    self.name = name
  }
}
