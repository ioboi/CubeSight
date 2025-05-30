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
  let performance: PlayerPerformance

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

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Tournament.self, configurations: config)

  let players = [
    TournamentPlayer(name: "Player 1"),
    TournamentPlayer(name: "Player 2"),
    TournamentPlayer(name: "Player 3"),
    TournamentPlayer(name: "Player 4"),
  ]

  let tournament = Tournament()
  tournament.players = players

  //Create some match results for preview
  let match1 = TournamentMatch(player1: players[0], player2: players[1])
  match1.complete(player1Wins: 2, player2Wins: 0, draws: 0)

  let match2 = TournamentMatch(player1: players[2], player2: players[3])
  match2.complete(player1Wins: 1, player2Wins: 1, draws: 1)

  let round1 = TournamentRound(matches: [match1, match2], roundIndex: 0)
  tournament.rounds.append(round1)

  container.mainContext.insert(tournament)

  return StandingsView(tournament: tournament)
    .modelContainer(container)
}
