import Foundation
import GRDB

enum ScryfallColor: String, Codable {
  case white = "W"
  case blue = "U"
  case black = "B"
  case red = "R"
  case green = "G"
  case colorless = "C"
}

extension ScryfallColor: DatabaseValueConvertible {}
