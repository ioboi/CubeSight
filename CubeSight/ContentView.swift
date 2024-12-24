//
//  ContentView.swift
//  CubeSight
//
//  Created by Noe on 15.12.2024.
//

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
      TournamentContentView()
        .tabItem {
          Label("Tournament", systemImage: "flag.pattern.checkered")
        }
        .tag(Tab.tournament)
    }
  }
}

#Preview {
  ContentView()
}

enum Tab {
  case cube
  case tournament
}
