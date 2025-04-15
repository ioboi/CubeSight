import SwiftUI

enum AppTabs: Codable, Hashable, Identifiable, CaseIterable {
  case cube

  var id: AppTabs { self }
}

extension AppTabs {
  var name: String {
    switch self {
    case .cube:
      String(localized: "Cube", comment: "Tab title")
    }
  }

  var symbol: String {
    switch self {
    case .cube:
      "text.page.badge.magnifyingglass"
    }
  }

  @ViewBuilder
  var content: some View {
    switch self {
    case .cube:
      CubeNavigationStack()
    }
  }
}
