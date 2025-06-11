import SwiftUI

enum AppTabs: Codable, Hashable, Identifiable, CaseIterable {
  case cube
  case tournament

  var id: AppTabs { self }
}

extension AppTabs {
  var name: String {
    switch self {
    case .cube:
      String(localized: "Cubes", comment: "Tab title")
    case .tournament:
      String(localized: "Tournaments", comment: "Tab title")
    }
  }

  var symbol: String {
    switch self {
    case .cube:
      "text.page.badge.magnifyingglass"
    case .tournament:
      "flag.pattern.checkered"
    }
  }

  @ViewBuilder
  var content: some View {
    switch self {
    case .cube:
      CubeNavigationStack()
    case .tournament:
      TournamentNavigationStack()
    }
  }
}
