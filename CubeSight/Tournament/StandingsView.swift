import SwiftData
import SwiftUI

private struct TableData: Identifiable {
  let player: TournamentPlayer
  let performance: TournamentPlayerPerformance

  var id: ObjectIdentifier { player.id }
}

struct StandingsView: View {
  var tournament: Tournament

  #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
  #else
    private let isCompact = false
  #endif

  private var sortedPlayerPerformances: [TableData] {
    tournament.performance.sorted {
      if $0.value.matchPoints != $1.value.matchPoints {
        return $0.value.matchPoints > $1.value.matchPoints
      } else if $0.value.gamePoints != $1.value.gamePoints {
        return $0.value.gamePoints > $1.value.gamePoints
      } else {
        return $0.key.name < $1.key.name
      }
    }.map { TableData(player: $0.key, performance: $0.value) }
  }

  var body: some View {
    if isCompact {
      List {
        LazyVGrid(
          columns: [
            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
          ],
          alignment: .leading
        ) {
          Text("Name").bold()
          Text("MP").bold()
          Text("GP").bold()
          ForEach(sortedPlayerPerformances) { performance in
            Text(performance.player.name)
            Text(performance.performance.matchPoints, format: .number)
            Text(performance.performance.gamePoints, format: .number)
          }
        }
      }
    } else {
      Table(sortedPlayerPerformances) {
        TableColumn("Name", value: \.player.name)
        TableColumn("MP") { performance in
          Text(performance.performance.matchPoints, format: .number)
        }
        TableColumn("GP") { performance in
          Text(performance.performance.gamePoints, format: .number)
        }
      }
      .navigationTitle("Standings")
    }
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
        tournament: Tournament.previewTournament,
        matches: [match1, match2, match3],
        roundIndex: 0
      )
      Tournament.previewTournament.rounds.append(round1)
    }
}
