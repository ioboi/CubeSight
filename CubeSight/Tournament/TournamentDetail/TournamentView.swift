import SwiftData
import SwiftUI

struct TournamentView: View {
  let tournament: Tournament

  var body: some View {
    switch tournament.status {
    case .seating:
      SeatingTournamentView(tournament: tournament)
    case .ongoing:
      OngoingTournamentView(tournament: tournament)
    case .ended:
      EndedTournamentView(tournament: tournament)
    }
  }
}

#Preview(traits: .sampleData) {
  TournamentView(tournament: Tournament.previewTournament)
}
