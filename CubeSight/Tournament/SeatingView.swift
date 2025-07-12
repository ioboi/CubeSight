import SwiftUI
import SwiftData

// TODO: Rename to proper name?
struct SeatingView<Content: View>: View {
  @Query private var tournamentPlayers: [TournamentPlayer] = []
  
  private let content: (TournamentPlayer) -> Content

  init(tournament: Tournament, @ViewBuilder content: @escaping (TournamentPlayer) -> Content) {
    self.content = content
    let id = tournament.persistentModelID
    let predicate = #Predicate<TournamentPlayer> {
      $0.tournament?.persistentModelID == id
    }
    _tournamentPlayers = Query(
      filter: predicate,
      sort: \TournamentPlayer.seating
    )
  }

  var body: some View {
    ForEach(tournamentPlayers, content: content)
  }
}
