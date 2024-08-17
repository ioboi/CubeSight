import SwiftUI
import Vision

struct DeckScanner: View {

  let cube: Cube
  @Binding var cards: [Card]

  @State private var isImagePicker = false
  @State private var selectedImage: UIImage?

  @State private var notFound: [(Int, Card, String)] = []

  var body: some View {
    List {
      if cards.isEmpty {
        Button("Choose Photo") {
          isImagePicker = true
        }
      }

      Section("Not found") {
        ForEach(notFound, id: \.2) { card in
          VStack(alignment: .leading) {
            Text(card.2)
            HStack {
              Text(card.1.name)
              Spacer()
              Text("\(card.0)")
            }.font(.caption)
          }

        }
      }

      Section {
        ForEach(cards) { card in
          HStack {
            SmallCardRow(card: card)
          }
        }
      } header: {
        Text("Found \(cards.count)")
      }
    }
    .sheet(isPresented: $isImagePicker) {
      ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
    }
    .onChange(of: selectedImage) { _, newValue in
      guard let image = newValue else { return }
      Task {
        await performTextRecognition(on: image)
      }
    }
  }

  func performTextRecognition(on image: UIImage) async {
    guard let cgImage = image.cgImage else { return }

    let request = VNRecognizeTextRequest { request, error in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

      var found: [Card] = []

      // TODO: Maybe get rectangles too.
      let possibleCards = Set(observations.compactMap { $0.topCandidates(1).first?.string })

      for possibleCard in possibleCards {

        // Search cube.
        if let card = cube.mainboard.first(where: { card in
          NSPredicate(format: "SELF CONTAINS[cd] %@", possibleCard).evaluate(with: card.name)
        }) {
          found.append(card)
          continue
        }

        guard
          let card = cube.mainboard.enumerated().map({ t in
            (t.element.name.getLevenshtein(target: possibleCard), t.element, possibleCard)
          }).min(by: { c1, c2 in
            c1.0 <= c2.0
          })
        else {
          continue
        }

        if card.0 <= 3 {
          found.append(card.1)
        } else {
          notFound.append(card)
        }
      }
    }

    request.customWords = cube.mainboard.map({ $0.name })
    request.recognitionLevel = .accurate

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
    do {
      try handler.perform([request])
    } catch {
      print("Error performing text recognition: \(error)")
    }
  }

}

/*#Preview {
  DeckScanner(cube: Cube(id: "", shortId: "", name: ""))
}*/
