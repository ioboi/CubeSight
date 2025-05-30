import SwiftData
import SwiftUI

struct StandingsView: View {
  var tournament: Tournament

  var body: some View {
    List {
      Section("Standings") {
        ForEach(sortedPlayers(), id: \.self) { player in
          if let performance = tournament.getPerformance(for: player) {
            PlayerStandingRow(player: player, performance: performance)
          } else {
            Text("No perfomance found for \(player.name)")
          }
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle("Standings")
  }

  private func sortedPlayers() -> [TournamentPlayer] {
    tournament.performance.sorted {
      if $0.value.matchPoints != $1.value.matchPoints {
        return $0.value.matchPoints > $1.value.matchPoints
      } else if $0.value.gamePoints != $1.value.gamePoints {
        return $0.value.gamePoints > $1.value.gamePoints
      } else {
        return $0.key.name < $1.key.name
      }
    }.map { $0.key }
  }
}

struct PlayerStandingRow: View {
  let player: TournamentPlayer
  let performance: TournamentPlayerPerformance

  var body: some View {
    HStack {
      Text(player.name)
      Spacer()
      Text("\(performance.matchPoints) MP | \(performance.gamePoints) GP")
        .font(.callout)
        .foregroundColor(.secondary)
    }
  }
}

#Preview(traits: .sampleData) {
  StandingsView(tournament: Tournament.previewTournament)
    .onAppear {
      let players = Tournament.previewTournament.players

      //Create some match results for preview
      let match1 = TournamentMatch(player1: players[0], player2: players[1])
      match1.complete(player1Wins: 2, player2Wins: 0, draws: 0)

      let match2 = TournamentMatch(player1: players[2], player2: players[3])
      match2.complete(player1Wins: 1, player2Wins: 1, draws: 1)

      let match3 = TournamentMatch(player1: players[4], player2: players[5])
      match2.complete(player1Wins: 0, player2Wins: 2, draws: 0)

      let round1 = TournamentRound(
        matches: [match1, match2, match3],
        roundIndex: 0
      )
      Tournament.previewTournament.rounds.append(round1)
    }
}
