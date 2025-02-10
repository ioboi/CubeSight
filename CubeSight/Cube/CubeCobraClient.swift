import Foundation
import OSLog

private let logger = Logger(subsystem: "CubeSight", category: "CubeCobraClient")

struct CubeCobraClient {

  struct Cube: Codable {
    struct Board: Codable {
      let mainboard: [Card]
    }

    struct Image: Codable {
      let uri: String
    }
    let id: String
    let shortId: String
    let name: String
    let cards: Board
    let image: Image?
  }

  struct Card: Codable {

    struct Details: Codable {
      enum CardColor: String, Codable {
        case blue = "U"
        case green = "G"
        case red = "R"
        case white = "W"
        case black = "B"
      }

      enum Colorcategory: String, Codable {
        case blue = "Blue"
        case green = "Green"
        case red = "Red"
        case white = "White"
        case black = "Black"
        case colorless = "Colorless"
        case multicolored = "Multicolored"
        case land = "Lands"
      }

      let name: String
      let imageNormal: String
      let imageSmall: String
      let colors: [CardColor]
      let colorcategory: Colorcategory
      let cmc: Int

      enum CodingKeys: String, CodingKey {
        case name
        case imageNormal = "image_normal"
        case imageSmall = "image_small"
        case colors
        case colorcategory
        case cmc
      }
    }

    let cardId: UUID
    let details: Details

    enum CodingKeys: String, CodingKey {
      case cardId = "cardID"
      case details
    }
  }

  private let cubeJSONEndpoint: String = "https://cubecobra.com/cube/api/cubeJSON/"
  private var decoder: JSONDecoder = JSONDecoder()

  func cube(shortId: String) async -> Cube? {
    let url = URL(string: "\(cubeJSONEndpoint)\(shortId)")!
    logger.info("Fetch cube with shortId=\(shortId), url=\(url.absoluteString)")
    let request = URLRequest(url: url)
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let result = try decoder.decode(Cube.self, from: data)
      return result
    } catch {
      logger.error("Failed to download cube: \(error)")
    }
    return nil
  }
}
