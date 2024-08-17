import PhotosUI
import SwiftData
import SwiftUI
import Vision

private enum CardScannerState {
  case start, searching, success
}

struct CardScannerView: View {

  let cube: Cube
  @Binding var selection: [Card]

  @State private var selectedImages: [PhotosPickerItem] = []
  @State private var state: CardScannerState = .start

  @State private var cards: [Card] = []
  @State private var invalidCards: [(Int, String, Card)] = []

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  var body: some View {
    // TODO: Implement "Capture photo"
    NavigationStack {
      Group {
        switch state {
        case .start:
          PhotosPicker(
            selection: $selectedImages,
            maxSelectionCount: 1,
            matching: .images
          ) {
            Text("Choose photo")
          }
        case .searching:
          ProgressView {
            Text("Searching for cards")
          }
        case .success:
          List {
            if !invalidCards.isEmpty {
              Section {
                ForEach(invalidCards, id: \.1) { invalidCard in
                  HStack {
                    Text(invalidCard.1)
                  }
                }
              } header: {
                Text("\(invalidCards.count) invalid cards")
              }
            }

            if !cards.isEmpty {
              Section {
                ForEach(cards) { card in
                  SmallCardRow(card: card)
                }
              } header: {
                Text("\(cards.count) cards")
              }
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            withAnimation {
              selection.append(contentsOf: cards)
              dismiss()
            }
          }
        }
      }
    }
    .onChange(of: selectedImages) { _, newValue in
      self.state = .searching
      Task {
        guard let selectedImage = selectedImages.first else { return }
        guard let imageData = try! await selectedImage.loadTransferable(type: Data.self) else {
          return
        }

        guard let image = UIImage(data: imageData) else { return }
        let possibleCards = await performTextRecognition(on: image)

        let found = cube.mainboard.filter { card in
          possibleCards.contains(where: { foundCardName in
            foundCardName.compare(card.name, options: [.diacriticInsensitive, .caseInsensitive])
              == .orderedSame
          })
        }

        let levenshteinCandidates = possibleCards.filter { foundCardName in
          !found.contains { card in
            foundCardName.compare(card.name, options: [.diacriticInsensitive, .caseInsensitive])
              == .orderedSame
          }
        }

        let base = levenshteinCandidates.compactMap { name in
          cube.mainboard.map { card in
            (card.name.getLevenshtein(target: name), name, card)
          }.min { a, b in
            a.0 < b.0
          }
        }

        invalidCards = base.filter {
          $0.0 >= 3
        }

        cards = found + invalidCards.filter { $0.0 < 3 }.map { $0.2 }
        state = .success
      }
    }
  }

  func performTextRecognition(on image: UIImage) async -> [String] {
    await withCheckedContinuation { continuation in
      guard let cgImage = image.cgImage else {
        continuation.resume(returning: [])
        return
      }

      let request = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
          continuation.resume(returning: [])
          return
        }
        let result = observations.compactMap { observation in
          observation.topCandidates(1).first?.string
        }
        continuation.resume(returning: result)
      }

      request.recognitionLevel = .accurate
      let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
      do {
        try handler.perform([request])
      } catch {
        continuation.resume(returning: [])
        print("Error performing text recognition: \(error)")
      }
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.sample) {
    CardScannerView(cube: Cube.sampleCube, selection: .constant([]))
  }
}
