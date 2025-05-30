import PhotosUI
import SwiftUI
import Vision

struct CubeCardsImportView: View {
  let cube: Cube
  @Binding var cards: Set<Card>

  @Environment(\.dismiss) private var dismiss: DismissAction

  var body: some View {
    NavigationStack {
      CubeDeckImport(cube: cube, cards: $cards)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Import")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel) {
              withAnimation {
                cards.removeAll()
                dismiss()
              }
            }
          }
        }
    }
  }
}

private struct CubeDeckImport: View {
  let cube: Cube
  @Binding var cards: Set<Card>

  private enum ImportState {
    case photopicker
    case ocr(data: Data)
  }

  @State private var importState: ImportState = .photopicker
  @State private var selection: [PhotosPickerItem] = []

  @ViewBuilder
  private var photosPicker: some View {
    PhotosPicker(
      selection: $selection,
      maxSelectionCount: 1,
      selectionBehavior: .default,
      matching: .images,
      preferredItemEncoding: .current,
      photoLibrary: .shared()
    ) {
      Text("Select photo")
    }
    .photosPickerStyle(.inline)
    .photosPickerDisabledCapabilities(.selectionActions)
    .photosPickerAccessoryVisibility(.hidden, edges: .bottom)
  }

  var body: some View {
    switch self.importState {
    case .photopicker:
      photosPicker
        .onChange(of: selection) { _, newValue in
          Task {
            guard let item = newValue.first else { return }
            guard let data = try? await item.loadTransferable(type: Data.self)
            else { return }
            importState = .ocr(data: data)
          }
        }
    case .ocr(let data):
      CardsOCRView(cube: cube, data: data, cards: $cards)
    }
  }
}

private struct CardsOCRView: View {
  let cube: Cube
  let data: Data
  @Binding var cards: Set<Card>

  @Environment(\.dismiss) var dismiss: DismissAction

  struct CardObservation {
    let card: Card
    let observation: RecognizedTextObservation
    let score: Int
  }

  @State private var cardObservations: [CardObservation] = []

  enum OCRState: Equatable {
    case loading
    case result(image: Image)
  }

  @State private var ocrState: OCRState = .loading

  var body: some View {
    List {
      switch ocrState {
      case .loading:
        EmptyView()
      case .result(let image):
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .listRowInsets(EdgeInsets())
          .overlay {
            ForEach(cardObservations, id: \.observation.uuid) { observation in
              Box(observation: observation.observation)
                .stroke(Color.red, lineWidth: 2)
            }
          }
        Section {
          ForEach(cardObservations, id: \.observation.uuid) { observation in
            VStack(alignment: .leading) {
              Text(observation.card.name)
                .badge(observation.score)
              Text(observation.observation.topCandidates(1).first?.string ?? "")
                .font(.caption)
            }
          }.onDelete(perform: removeCards)
        } header: {
          Text("Cards found: \(cardObservations.count)")
        }
      }
    }
    .overlay {
      if ocrState == .loading {
        ProgressView()
          .task {
            do {
              try await performOCR()
            } catch {
              // TODO: Handle error
              print(error)
            }
          }
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Done") {
          withAnimation {
            cards = Set(cardObservations.map(\.card))
            dismiss()
          }
        }
      }
    }
  }

  private func removeCards(indexSet: IndexSet) {
    for index in indexSet {
      let observation = cardObservations.remove(at: index)
      cards.remove(observation.card)
    }
  }

  private func performOCR() async throws {
    let observations = try await RecognizeTextRequest().perform(on: data)
    guard let uiImage = UIImage(data: data) else { return }

    for observation in observations {
      guard let topCandidate = observation.topCandidates(1).first?.string else {
        continue
      }

      // Tuple containing (score, Card)
      let possibleCard = cube.mainboard
        .map { ($0.name.getLevenshtein(target: topCandidate), $0) }
        .min { c1, c2 in
          c1.0 <= c2.0
        }
      guard let possibleCard else { continue }

      // Card is found with max 2 errors
      if possibleCard.0 <= 2 {
        cardObservations.append(
          CardObservation(
            card: possibleCard.1,
            observation: observation,
            score: possibleCard.0
          )
        )
      }
    }

    ocrState = .result(image: Image(uiImage: uiImage))
  }
}

private struct Box: Shape {
  private let normalizedRect: NormalizedRect

  init(observation: any BoundingBoxProviding) {
    normalizedRect = observation.boundingBox
  }

  func path(in rect: CGRect) -> Path {
    let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
    return Path(rect)
  }
}

#Preview(traits: .sampleData) {
  CubeCardsImportView(cube: Cube.sampleCube, cards: .constant([]))
}

#Preview("Cards OCR", traits: .sampleData) {
  CardsOCRView(
    cube: Cube.sampleCube,
    data: UIImage(resource: .exampleDeck).pngData()!,
    cards: .constant([])
  )
}
