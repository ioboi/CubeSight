import SwiftData
import SwiftUI

private let maxWins = 3 // picker range and color scale center

struct MatchView: View {
  let match: TournamentMatch
  @State private var player1Wins: Int
  @State private var player2Wins: Int

  init(match: TournamentMatch) {
    self.match = match
    player1Wins = match.player1Wins
    player2Wins = match.player2Wins
  }
  
  var body: some View {
    VStack {
      HStack {
        // Player 1
        playerScore(
          name: match.player1.name,
          wins: $player1Wins,
          background: backgroundColor(player1Wins, player2Wins)
        )

        Text("vs")
          .bold()
          .padding()

        // Player 2
        playerScore(
          name: match.player2.name,
          wins: $player2Wins,
          background: backgroundColor(player2Wins, player1Wins)
        )
      }
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
  }
  
  private func confirmChanges() {
    let draws = player1Wins == player2Wins ? 1 : 0
    match.complete(
      player1Wins: player1Wins,
      player2Wins: player2Wins,
      draws: draws,
    )
  }
  
  private func playerScore(
    name: String,
    wins: Binding<Int>,
    background: Color,
  ) -> some View {
    
    Menu {
      Text("\(name)")
        ForEach(0...Int(maxWins), id: \.self) { value in
          Button("\(value)") {
            wins.wrappedValue = value
          }
        }
      } label: {
        VStack {
          Text(name.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)

          Text("\(wins.wrappedValue)")
            .font(.system(size: 54, weight: .black, design: .rounded))
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(background)
      }
      .buttonStyle(.plain)
      .onChange(of: wins.wrappedValue) {
        confirmChanges()
      }
  }
  
  private func backgroundColor(_ playerWins: Int, _ opponentWins: Int) -> Color {
    
    // No entry
    if (player1Wins == 0 && player2Wins == 0) {
      return Color.gray.opacity(0.3)
    }
    
    let diff = playerWins - opponentWins
    
    // Draw
    if diff == 0 {
      return Color.yellow.opacity(0.3)
    }

    // Scale diff relative to configured color steps
    let clamped = max(-maxWins, min(maxWins, diff))
    let intensity = Double(abs(clamped)) / Double(maxWins)

    if diff > 0 {
      // Winner
      return Color.green.opacity(intensity)
    } else {
      // Loser
      return Color.red.opacity(intensity)
    }
  }
}

#Preview {
  ScrollView {
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(player: Player(name: "Alice has a really long name")),
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
}
