import SwiftData
import SwiftUI

struct OngoingTournamentView: View {
  let tournament: Tournament
  @State private var isConfirmationRoundDeletionPresented: Bool = false
  @State private var roundToDelete: TournamentRound?

  @Query private var rounds: [TournamentRound]
  @Environment(\.modelContext) private var modelContext: ModelContext

  init(tournament: Tournament) {
    self.tournament = tournament

    let tournamentId = tournament.persistentModelID
    let roundsPredicate = #Predicate<TournamentRound> { round in
      round.tournament.persistentModelID == tournamentId
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
                withAnimation {
                  confirmDropRound(round)
                }
              }
              .font(.headline)
              .labelStyle(.iconOnly)
              .confirmationDialog(
                "Drop Round?",
                isPresented: $isConfirmationRoundDeletionPresented,
                actions: {
                  Button("Drop Round", role: .destructive, action: dropRound)
                }
              )
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
          }
        }
        .headerProminence(.increased)
      }

      Section {
        Button("Next Round", systemImage: "arrow.trianglehead.clockwise") {
          withAnimation {
            startNextRound()
          }
        }
        .disabled(!lastRoundComplete)
      }
    }
  }

  private func finishTournament() {
    tournament.status = .ended
  }

  private func confirmDropRound(_ round: TournamentRound) {
    roundToDelete = round
    isConfirmationRoundDeletionPresented = true
  }

  private func dropRound() {
    guard let roundToDelete else { return }
    modelContext.delete(roundToDelete)
    // Make sure that tournaments is up-to-date for the next "startNextRound"
    try? modelContext.save()
    self.roundToDelete = nil
    self.isConfirmationRoundDeletionPresented = false
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
