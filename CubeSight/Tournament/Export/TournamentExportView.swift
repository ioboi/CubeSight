import SwiftData
import SwiftUI
import TabularData
import Zip

struct TournamentExportView: View {
  let tournament: Tournament

  @State private var isShareSheetPresented: Bool = false

  private enum ExportState {
    case exporting
    case done(URL)
    case error(Error)
  }

  @State private var exportState: ExportState = .exporting

  var body: some View {
    switch exportState {
    case .exporting:
      ProgressView("Preparing export")
        .task {
          await export()
        }
    case .done(let url):
      VStack {
        Text(url.lastPathComponent)
        ShareLink("Share File", item: url)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
      }
    // TODO: Share Button
    case .error(let error):
      Text("Error: \(error)")  //TODO: Make it better!
    }
  }

  private func export() async {
    let documentsDirectory = FileManager.default.temporaryDirectory

    do {
      struct MatchExport: Codable {
        let tournamentDate: Date
        let round: Int
        let player1: String
        let player2: String
        let player1Wins: Int
        let player2Wins: Int
        let draws: Int
      }

      let matches = tournament.rounds
        .map { ($0.roundIndex, $0.matches) }
        .flatMap { roundIndex, matches in
          matches.map { match in
            MatchExport(
              tournamentDate: Calendar.current.startOfDay(
                for: tournament.createdAt
              ),
              round: roundIndex + 1,
              player1: match.player1.name,
              player2: match.player2.name,
              player1Wins: match.player1Wins,
              player2Wins: match.player2Wins,
              draws: match.draws
            )
          }
        }

      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601

      let tournamentData = try encoder.encode(matches)
      let tournamentDataFrame = try DataFrame(jsonData: tournamentData)

      let formatter = {
        let result = DateFormatter()
        result.dateFormat = "yyyy_MM_dd"
        return result
      }()

      let tournamentExportName =
        "\(formatter.string(from: tournament.createdAt))_matches.csv"

      let fileURL = documentsDirectory.appendingPathComponent(
        tournamentExportName
      )
      try tournamentDataFrame.writeCSV(to: fileURL)

      struct CardExport: Codable {
        let tournament: Date
        let player: String
        let scryfallId: String
        let quantity: Int
        let archetype: String
        let decktype: String
      }

      let tournamentDate = Calendar.current.startOfDay(
        for: tournament.createdAt
      )

      let tournamentDraftedDecks = tournament.players
        .compactMap { $0.draftedDeck }
        .flatMap { draftedDeck in
          draftedDeck.cards.map { card in
            CardExport(
              tournament: tournamentDate,
              player: draftedDeck.tournamentPlayer!.name,
              scryfallId: card.card.scryfallId,
              quantity: card.quantity,
              archetype: draftedDeck.archetype?.name ?? "",
              decktype: draftedDeck.decktype
            )
          }
        }

      let draftedDeckData = try encoder.encode(tournamentDraftedDecks)
      let draftedDeckDataFrame = try DataFrame(jsonData: draftedDeckData)

      let draftedDeckExportName =
        "\(formatter.string(from: tournament.createdAt))_drafted_decks.csv"

      let draftedDeckFileURL = documentsDirectory.appendingPathComponent(
        draftedDeckExportName
      )
      try draftedDeckDataFrame.writeCSV(to: draftedDeckFileURL)

      let zipFilePath = documentsDirectory.appendingPathComponent(
        "\(formatter.string(from: tournament.createdAt))_tournament_export.zip"
      )
      try Zip.zipFiles(
        paths: [fileURL, draftedDeckFileURL],
        zipFilePath: zipFilePath,
        password: nil,
        progress: nil
      )

      // Cleanup csvs
      try FileManager.default.removeItem(at: fileURL)

      // TODO: Clean up zips

      exportState = .done(zipFilePath)
    } catch {
      self.exportState = .error(error)
    }
  }
}

#Preview(traits: .sampleData) {
  TournamentExportView(tournament: Tournament.previewTournament)
}
