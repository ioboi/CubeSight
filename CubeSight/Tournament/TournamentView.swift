import SwiftData
import SwiftUI

struct TournamentView: View {
  private let tournament: Tournament

  init(tournament: Tournament) {
    self.tournament = tournament
  }

  private var currentRoundComplete: Bool {
    guard let currentRound = tournament.rounds.last else { return true }
    return currentRound.matches.allSatisfy { $0.isComplete() }
  }

  var body: some View {
    List {
      NavigationLink("Standings") {
        StandingsView(tournament: tournament)
      }
      Section(
        header:
          // TODO: add asc / desc button?
          Text("Rounds")
      ) {
        ForEach(tournament.rounds.indices, id: \.self) { roundIndex in
          Section(header: Text("Round \(roundIndex + 1)")) {
            // TODO: Put into RoundView?
            ForEach(tournament.rounds[roundIndex].matches.indices, id: \.self) {
              matchIndex in
              MatchView(
                match: tournament.rounds[roundIndex].matches[matchIndex]
              )
            }
          }
        }
      }

      if currentRoundComplete {
        Section {
          Button(action: {
            tournament.startNextRound(strategy: SwissPairingStrategy())
          }) {
            HStack {
              Text("Start Round \(tournament.rounds.count + 1)")
              Spacer()
              Image(systemName: "plus.circle.fill")
            }
          }
          .foregroundColor(.blue)
        }
      }
    }
    .navigationTitle("Tournament")
  }
}

#Preview(traits: .sampleData) {
  TournamentView(tournament: Tournament.previewTournament)
    .onAppear {
      Tournament.previewTournament.startNextRound(
        strategy: SwissPairingStrategy()
      )
    }
}
