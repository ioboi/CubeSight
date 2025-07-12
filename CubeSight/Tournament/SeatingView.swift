import SwiftUI
import SwiftData

// TODO: Rename to proper name?
struct SeatingView: View {
  @Query private var tournamentPlayers: [TournamentPlayer] = []

  init(tournament: Tournament) {
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
    ForEach(tournamentPlayers) { tournamentPlayer in
      HStack {
        Image(systemName: "person")
        Text(tournamentPlayer.player.name)
      }
    }
  }
}
