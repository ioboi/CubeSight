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

    let tournamentId = tournament.id
    let roundsPredicate = #Predicate<TournamentRound> { round in
      round.tournament.id == tournamentId
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

      ForEach(rounds) { round in
        Section {
          ForEach(round.matches) { match in
            MatchView(match: match)
              .disabled(round != rounds.last)  // Only score last round?
          }
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
    self.roundToDelete = nil
    self.isConfirmationRoundDeletionPresented = false
  }

  private func startNextRound() {
    tournament.startNextRound()
  }
}

#Preview(traits: .sampleData) {
  TournamentView(tournament: Tournament.previewTournament)
    .onAppear {
      Tournament.previewTournament.startNextRound()
    }
}
