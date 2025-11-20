import SwiftData
import SwiftUI

private let maxWins = 3 // picker range and color scale center

struct MatchView: View {
  let match: TournamentMatch
  @State private var player1Wins: Int
  @State private var player2Wins: Int
  @State private var hasPendingChanges = false
  @State private var showingPickerForPlayer1 = false
  @State private var showingPickerForPlayer2 = false

  init(match: TournamentMatch) {
    self.match = match
    _player1Wins = State(initialValue: match.player1Wins)
    _player2Wins = State(initialValue: match.player2Wins)
  }
  
  var body: some View {
    VStack {
      HStack {
        // Player 1
        playerColumn(
          name: match.player1.name,
          wins: $player1Wins,
          background: backgroundColor(for: player1Wins - player2Wins),
          isShowingPicker: $showingPickerForPlayer1
        )

        Text("vs")
          .bold()
          .padding()

        // Player 2
        playerColumn(
          name: match.player2.name,
          wins: $player2Wins,
          background: backgroundColor(for: player2Wins - player1Wins),
          isShowingPicker: $showingPickerForPlayer2
        )
      }
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .shadow(radius: 5)
      .frame(maxWidth: .infinity)
      
      if hasPendingChanges {
        Button("Confirm") {
          confirmChanges()
        }
        .buttonStyle(.borderedProminent)
        .transition(.opacity)
        .frame(maxWidth: .infinity)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .contentShape(Rectangle())
    .onChange(of: player1Wins) {
      markPendingChange()
    }
    .onChange(of: player2Wins) {
      markPendingChange()
    }
    .animation(.easeInOut, value: hasPendingChanges)
  }
  
  private func markPendingChange() {
    // Show confirm button if user changed anything
    hasPendingChanges = player1Wins != match.player1Wins || player2Wins != match.player2Wins
  }
  
  private func confirmChanges() {
    let draws = player1Wins == player2Wins ? 1 : 0
    match.complete(
      player1Wins: player1Wins,
      player2Wins: player2Wins,
      draws: draws
    )
    hasPendingChanges = false
  }
  
  private func playerColumn(
    name: String,
    wins: Binding<Int>,
    background: Color,
    isShowingPicker: Binding<Bool>
  ) -> some View {
    Button {
      isShowingPicker.wrappedValue = true
    } label: {
      VStack(spacing: 4) {
        Text(name)
          .bold()
          .frame(maxWidth: .infinity, alignment: .center)

        Text("Wins: \(wins.wrappedValue)")
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 4)
          .background(Color.white.opacity(0.1))
          .cornerRadius(5)
      }
      .padding(6)
      .frame(maxWidth: .infinity)
      .background(background)
    }
    .buttonStyle(.plain)
    .confirmationDialog("Select Wins for \(name)", isPresented: isShowingPicker) {
      ForEach(0..<Int(maxWins+1), id: \.self) { value in
        Button("\(value)") {
          wins.wrappedValue = value
        }
      }
    }
  }
  
  private func backgroundColor(for diff: Int) -> Color {
    if diff == 0 {
      return Color.yellow.opacity(0.3)
      
    }

    // Scale diff relative to configured color steps
    let clamped = max(-maxWins, min(maxWins, diff))
    let intensity = Double(abs(clamped)) / Double(maxWins)

    if diff > 0 {
      return Color.green.opacity(0.3 + 0.6 * intensity)
    } else {
      return Color.red.opacity(0.3 + 0.6 * intensity)
    }
  }
}

#Preview {
  ScrollView {
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(player: Player(name: "Alice")),
        player2: TournamentPlayer(player: Player(name: "Bob"))
      )
    )
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(player: Player(name: "Jon")),
        player2: TournamentPlayer(player: Player(name: "Doe"))
      )
    )
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(player: Player(name: "Why")),
        player2: TournamentPlayer(player: Player(name: "Doe"))
      )
    )
  }
//  .frame(maxWidth: .infinity)
  .background(Color(uiColor: .systemGroupedBackground))
}
