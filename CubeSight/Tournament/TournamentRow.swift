import SwiftUI

struct TournamentRow: View {
  let tournament: Tournament

  var body: some View {
    HStack {
      Text(tournament.createdAt, style: .date)
        .bold()
      Spacer()
      Label("\(tournament.players.count) participants", systemImage: "person.3")
    }
    .font(.subheadline)
  }
}

#Preview {
  List {
    TournamentRow(tournament: Tournament.previewTournament)
  }
}
