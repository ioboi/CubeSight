import Foundation
import SwiftData

@Model
class Player {
  var id: UUID
  var name: String
  var tournaments = [Tournament]()

  init(name: String) {
    self.id = UUID()
    self.name = name
  }
}
