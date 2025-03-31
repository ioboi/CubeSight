import SwiftUI

struct AppTabView: View {
  @State private var selectedTab: AppTabs = .cube

  var body: some View {
    TabView(selection: $selectedTab) {
      ForEach(AppTabs.allCases) { appTab in
        Tab(appTab.name, systemImage: appTab.symbol, value: appTab) {
          appTab.content
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  AppTabView()
}
