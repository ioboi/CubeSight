import SwiftUI

struct ContentView: View {
  @State private var selectedTab: Tab = .cube
  var body: some View {
    TabView(selection: $selectedTab) {
      CubeContentView()
        .tabItem {
          Label("Cube", systemImage: "text.page.badge.magnifyingglass")
        }
        .tag(Tab.cube)
    }
  }
}

#Preview {
  ContentView()
}

enum Tab {
  case cube
}
