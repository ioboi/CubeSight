import SwiftUI

struct TournamentRoundEditor: View {
  private var tournamentRound: TournamentRound
  private var availablePlayers: [TournamentPlayer]
  
  init(tournamentRound: TournamentRound) {
    self.tournamentRound = tournamentRound
    self.availablePlayers = tournamentRound.matches.flatMap {
      [$0.player1, $0.player2]
    }.sorted { $0.name < $1.name }
  }
  
  var body: some View {
    List {
      ForEach(tournamentRound.matches) { match in
        HStack {
          Text(match.player1.name)
          Spacer()
          Text("vs.")
          Spacer()
          Menu {
            ForEach(availablePlayers.filter { $0 != match.player1 }) { otherPlayer in
              Button(otherPlayer.name) {
                swapPlayer2(in: match, with: otherPlayer)
              }
            }
          } label: {
            Text(match.player2.name)
          }
        }
      }
      // TODO: Damn this is ugly!
      ForEach(tournamentRound.matches) { match in
        HStack {
          Text(match.player2.name)
          Spacer()
          Text("vs.")
          Spacer()
          Menu {
            ForEach(availablePlayers.filter { $0 != match.player2 }) { otherPlayer in
              Button(otherPlayer.name) {
                swapPlayer1(in: match, with: otherPlayer)
              }
            }
          } label: {
            Text(match.player1.name)
          }
        }
      }
    }
    .navigationTitle("Adjust pairings")
  }
  
  // TODO: This could be improved much with thinking a bit more, but ok at the moment
  private func swapPlayer2(in match: TournamentMatch, with other: TournamentPlayer) {
    let before = match.player2
    guard let otherMatch = tournamentRound.matches.first(where: { $0.player1 == other || $0.player2 == other })  else { return }
    if otherMatch.player1 == other {
      otherMatch.player1 = before
    }
    if otherMatch.player2 == other {
      otherMatch.player2 = before
    }
    match.player2 = other
  }
  
  private func swapPlayer1(in match: TournamentMatch, with other: TournamentPlayer) {
    let before = match.player1
    guard let otherMatch = tournamentRound.matches.first(where: { $0.player1 == other || $0.player2 == other })  else { return }
    if otherMatch.player1 == other {
      otherMatch.player1 = before
    }
    if otherMatch.player2 == other {
      otherMatch.player2 = before
    }
    match.player1 = other
  }
}

#Preview(traits: .sampleData) {
  TournamentRoundEditor(
    tournamentRound: TournamentRound(
      tournament: Tournament.previewTournament,
      matches: [
        .init(
          player1: .init(player: .init(name: "A")),
          player2: .init(player: .init(name: "B"))
        ),
        .init(
          player1: .init(player: .init(name: "C")),
          player2: .init(player: .init(name: "D"))
        ),
      ],
      roundIndex: 0
    )
  )
}
