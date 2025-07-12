import SwiftData
import SwiftUI

private enum Score: String, CaseIterable {
  case none = "No score"
  case twoZero = "2-0"
  case twoOne = "2-1"
  case oneZero = "1-0"
  case oneOne = "1-1"
  case zeroZero = "0-0"
  case zeroOne = "0-1"
  case oneTwo = "1-2"
  case zeroTwo = "0-2"

  var wins: (player1Wins: Int, player2Wins: Int) {
    switch self {
    case .twoZero: return (2, 0)
    case .twoOne: return (2, 1)
    case .oneZero: return (1, 0)
    case .oneOne: return (1, 1)
    case .zeroZero: return (0, 0)
    // Define none as 0-0, TODO: check if this is correct
    case .none: return (0, 0)
    case .zeroTwo: return (0, 2)
    case .oneTwo: return (1, 2)
    case .zeroOne: return (0, 1)
    }
  }

  static var availableScores: [Score] = [
    twoZero,
    twoOne,
    oneZero,
    oneOne,
    zeroZero,
    zeroOne,
    oneTwo,
    zeroTwo,
  ]

  static func from(_ match: TournamentMatch) -> Score {
    if !match.isComplete {
      return Score.none
    }

    // 2-0
    if match.player1Wins == 2 && match.player2Wins == 0 {
      return Score.twoZero
    }
    // 2-1
    if match.player1Wins == 2 && match.player2Wins == 1 {
      return Score.twoOne
    }

    // 2-0
    if match.player1Wins == 2 && match.player2Wins == 0 {
      return Score.twoZero
    }

    // 1-0
    if match.player1Wins == 1 && match.player2Wins == 0 {
      return Score.oneZero
    }

    // 1-1
    if match.player1Wins == 1 && match.player2Wins == 1 {
      return Score.oneOne
    }

    // 0-0
    if match.player1Wins == 0 && match.player2Wins == 0 {
      return Score.zeroZero
    }

    // 0-2
    if match.player1Wins == 0 && match.player2Wins == 2 {
      return Score.zeroTwo
    }

    // 1-2
    if match.player1Wins == 1 && match.player2Wins == 2 {
      return Score.oneTwo
    }

    // 0-1
    if match.player1Wins == 0 && match.player2Wins == 1 {
      return Score.zeroOne
    }

    return .none
  }
}

struct MatchView: View {
  let match: TournamentMatch
  @State private var showingScoreSheet = false

  var body: some View {
    HStack {
      Text(match.player1.name)
        .bold()
        + Text(" vs ")
        + Text(match.player2.name)
        .bold()
      Spacer()
      Menu {
        ForEach(Score.availableScores, id: \.self) { score in
          Button(action: { scoreMatch(score: score) }) {
            Text(score.rawValue)
          }
        }
      } label: {
        let score = Score.from(match)
        Text(score == .none ? "Score" : score.rawValue)
      }
    }
  }
  private func scoreMatch(score: Score) {
    if score == .none { return }
    let (player1Wins, player2Wins) = score.wins
    match.complete(
      player1Wins: player1Wins,
      player2Wins: player2Wins,
      draws: player1Wins == player2Wins ? 1 : 0
    )
  }
}

#Preview {
  List {
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(player: Player(name: "Alice")),
        player2: TournamentPlayer(player: Player(name: "Bob"))
      )
    )
  }
}
