import SwiftUI

struct TournamentRow: View {
  let tournament: Tournament

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(tournament.createdAt, style: .date)
          .bold()
        Text(tournament.status == .inProgress ? "In Progress" : "Finished")
          .font(.caption)
      }
      
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
