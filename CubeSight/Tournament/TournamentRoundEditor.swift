import SwiftUI

struct TournamentRoundEditor: View {
  private var tournamentRound: TournamentRound
  private var availablePlayers: [TournamentPlayer]

  init(tournamentRound: TournamentRound) {
    self.tournamentRound = tournamentRound
    self.availablePlayers = tournamentRound.matches.map { $0.player2 }
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
            ForEach(tournamentRound.matches) { otherMatch in
              Button(otherMatch.player2.name) {
                let matchPlayer2 = match.player2
                match.player2 = otherMatch.player2
                otherMatch.player2 = matchPlayer2
              }
            }
          } label: {
            Text(match.player2.name)
          }
        }
      }
    }
    .navigationTitle("Adjust pairings")
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
