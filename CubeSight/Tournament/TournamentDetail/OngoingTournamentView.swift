import SwiftData
import SwiftUI

struct OngoingTournamentView: View {
  let tournament: Tournament
  @State private var isConfirmationRoundDeletionPresented: Bool = false

  @Query private var rounds: [TournamentRound]
  @Environment(\.modelContext) private var modelContext: ModelContext

  init(tournament: Tournament) {
    self.tournament = tournament

    let tournamentId = tournament.persistentModelID
    let roundsPredicate = #Predicate<TournamentRound> { round in
      round.tournament?.persistentModelID == tournamentId
    }
    self._rounds = Query(
      filter: roundsPredicate,
      sort: [SortDescriptor(\.roundIndex)]
    )
  }

  private var lastRoundComplete: Bool {
    rounds.last?.matches.allSatisfy { $0.isComplete } ?? true
  }

  var body: some View {
    List {
      NavigationLink("Initial Seating") {
        List {
          SeatingView(tournament: tournament)
        }
      }
      NavigationLink("Standings") {
        StandingsView(tournament: tournament)
      }

      ForEach(tournament.rounds) { round in
        Section {
          Matches(round: round)
            .disabled(round != rounds.last)
        } header: {
          HStack {
            Text("Round \(round.roundIndex + 1)")
            if round == rounds.last && round != rounds.first {
              Spacer()
              Button("Drop Round", systemImage: "trash", role: .destructive) {
                isConfirmationRoundDeletionPresented = true
              }
              .font(.headline)
              .labelStyle(.iconOnly)
              .confirmationDialog(
                "Drop Round?",
                isPresented: $isConfirmationRoundDeletionPresented,
                actions: {
                  Button("Drop Round", role: .destructive) {
                    isConfirmationRoundDeletionPresented = false
                    withAnimation {
                      modelContext.delete(round)
                      try? modelContext.save()
                    }
                  }
                }
              )
            }
          }
          .headerProminence(.increased)
        }
      }

      Section {
        Button(
          "Next Round",
          systemImage: "arrow.trianglehead.clockwise") {
            withAnimation {
              startNextRound()
            }
          }
        .disabled(!lastRoundComplete)
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("End", action: finishTournament)
          .disabled(!lastRoundComplete)
      }
      ToolbarItem(placement: .principal) {
        Text("Tournament")
      }
    }
  }

  private func finishTournament() {
    tournament.status = .ended
  }

  private func startNextRound() {
    let newMatches = SwissPairingStrategy().createPairings(
      for: tournament.players,
      with: tournament.performance
    )
    let newRound = TournamentRound(
      tournament: tournament,
      matches: newMatches,
      roundIndex: rounds.count
    )
    modelContext.insert(newRound)
    try? modelContext.save()
  }
}

private struct Matches: View {
  let round: TournamentRound
  var body: some View {
    ForEach(round.matches) { match in
      MatchView(match: match)
    }
  }
}

#Preview(traits: .sampleData) {
  TournamentView(tournament: Tournament.previewTournament)
    .onAppear {
      Tournament.previewTournament.startNextRound()
    }
}
