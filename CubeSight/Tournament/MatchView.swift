import SwiftData
import SwiftUI

struct MatchView: View {
  let match: TournamentMatch
  @State private var showingScoreSheet = false

  var body: some View {
    HStack {
      Text("\(match.player1.name) vs \(match.player2.name)")
        .font(.body)

      Spacer()

      if match.isComplete() {
        Text(resultText)
          .foregroundColor(.secondary)
      } else {
        Button(action: {
          showingScoreSheet = true
        }) {
          Text("Record")
            .foregroundColor(.blue)
        }
      }
    }
    .padding()
    .sheet(isPresented: $showingScoreSheet) {
      NavigationView {
        MatchResultSelection(match: match, isPresented: $showingScoreSheet)
      }
    }
    .swipeActions(edge: .trailing) {
      if match.isComplete() {
        Button {
          showingScoreSheet = true
        } label: {
          Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
      }
    }
  }

  private var resultText: String {
    if match.player1Wins + match.player2Wins + match.draws == 0 {
      return "No games played"
    }
    return "\(match.player1Wins)-\(match.player2Wins)"
  }
}

struct MatchResultSelection: View {
  let match: TournamentMatch
  @Binding var isPresented: Bool

  enum Outcome: String, CaseIterable {
    case player1Wins = "Player 1 Wins"
    case player2Wins = "Player 2 Wins"
    case draw = "Draw"
  }

  var body: some View {
    List {
      Section {
        NavigationLink(
          destination: ScoreOptionsView(
            match: match, outcome: .player1Wins, isPresented: $isPresented)
        ) {
          Text("\(match.player1.name) Wins")
        }

        NavigationLink(
          destination: ScoreOptionsView(
            match: match, outcome: .player2Wins, isPresented: $isPresented)
        ) {
          Text("\(match.player2.name) Wins")
        }

        NavigationLink(
          destination: ScoreOptionsView(match: match, outcome: .draw, isPresented: $isPresented)
        ) {
          Text("Draw")
        }
      }
    }
    .navigationTitle("Select Winner")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          isPresented = false
        }
      }
    }
  }
}

struct ScoreOptionsView: View {
  let match: TournamentMatch
  let outcome: MatchResultSelection.Outcome
  @Binding var isPresented: Bool
  @State private var selectedScore: Score?

  enum Score: String, CaseIterable {
    case twoZero = "2-0"
    case twoOne = "2-1"
    case oneZero = "1-0"
    case oneOne = "1-1"
    case zeroZero = "0-0"
    case zeroTwo = "0-2"  // Adding reversed scores
    case oneTwo = "1-2"
    case zeroOne = "0-1"

    var scores: (player1: Int, player2: Int) {
      switch self {
      case .twoZero: return (2, 0)
      case .twoOne: return (2, 1)
      case .oneZero: return (1, 0)
      case .oneOne: return (1, 1)
      case .zeroZero: return (0, 0)
      case .zeroTwo: return (0, 2)
      case .oneTwo: return (1, 2)
      case .zeroOne: return (0, 1)
      }
    }
  }

  var availableScores: [Score] {
    switch outcome {
    case .player1Wins:
      return [.twoOne, .twoZero, .oneZero]
    case .player2Wins:
      return [.oneTwo, .zeroTwo, .zeroOne]  // Using predefined reversed scores
    case .draw:
      return [.oneOne, .zeroZero]
    }
  }

  var body: some View {
    List {
      Section {
        ForEach(availableScores, id: \.self) { score in
          Button(action: {
            selectedScore = score
            let scores = score.scores
            match.complete(
              player1Wins: scores.player1,
              player2Wins: scores.player2,
              draws: scores.player1 == scores.player2 ? 1 : 0
            )
            isPresented = false
          }) {
            Text(score.rawValue)
          }
        }
      } footer: {
        if outcome == .player2Wins {
          Text("Scores shown from \(match.player2.name)'s perspective")
        }
      }
    }
    .navigationTitle("Select Score")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  List {
    // Incomplete match
    MatchView(
      match: TournamentMatch(
        player1: TournamentPlayer(name: "Alice"),
        player2: TournamentPlayer(name: "Bob")
      ))

    // Complete match with a result
    MatchView(
      match: {
        let match = TournamentMatch(
          player1: TournamentPlayer(name: "Carol"),
          player2: TournamentPlayer(name: "David")
        )
        match.complete(player1Wins: 2, player2Wins: 1, draws: 0)
        return match
      }())

    // Complete match with no games
    MatchView(
      match: {
        let match = TournamentMatch(
          player1: TournamentPlayer(name: "Eve"),
          player2: TournamentPlayer(name: "Frank")
        )
        match.complete(player1Wins: 0, player2Wins: 0, draws: 0)
        return match
      }())
  }
}
