import SwiftUI
import SwiftData
import PhotosUI
import Vision

struct DeckScanner: View {
  
  enum ImageState {
    case empty
    case loading(Progress)
    case success(UIImage)
    case failure(Error)
  }
  
  @State private(set) var imageState: ImageState = .empty
  @State private var imageSelection: PhotosPickerItem? = nil {
    didSet {
      if let imageSelection {
        let progress = loadTransferable(from: imageSelection)
        imageState = .loading(progress)
      } else {
        imageState = .empty
      }
    }
  }
  
  var body: some View {
    VStack {
      switch imageState {
      case .empty:
        PhotosPicker(selection: $imageSelection) {
          Text("Select Photo")
        }
        .photosPickerStyle(.inline)
        .photosPickerDisabledCapabilities(.selectionActions)
      case .success(let image):
        CardsRecognitionView(image: image)
      case .failure(let error):
        Text("Error: \(error)")
      default:
        ProgressView()
      }
      
    }
    .onChange(of: imageSelection) { _, newValue in
      if let newValue {
        let progress = loadTransferable(from: newValue)
        imageState = .loading(progress)
      } else {
        imageState = .empty
      }
    }
  }
  
  private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
    return imageSelection.loadTransferable(type: Data.self) { result in
      DispatchQueue.main.async {
        guard imageSelection == self.imageSelection else {
          print("Failed to get the selected item.")
          return
        }
        switch result {
        case .success(let data?):
          self.imageState = .success(UIImage(data: data)!)
        case .success(nil):
          self.imageState = .empty
        case .failure(let error):
          self.imageState = .failure(error)
        }
      }
    }
  }
}

struct CardsRecognitionView: View {
  
  let image: UIImage
  @Environment(\.modelContext) private var modelContext
  
  @State private var cardOCR = CardOCR()
  
  enum CardsRecognitionState {
    case loading
    case success
  }
  
  @State private var state: CardsRecognitionState = .loading
  
  var body: some View {
    switch state {
    case .loading:
      ProgressView {
        Text("Analyzing cards on image.")
      }.task {
        await cardOCR.perform(with: modelContext, on: image)
        state = .success
      }
    case .success:
      List {
        Section {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .listRowInsets(EdgeInsets())
            .overlay {
              ForEach(cardOCR.observations, id: \.observation.uuid) { observation in
                Box(observation: observation.observation)
                  .stroke(Color.green)
              }
            }
        }
        ForEach(cardOCR.observations, id: \.observation.uuid) { observation in
          SmallCardRow(card: observation.card)
        }
      }
    }
  }
}

@Observable
@MainActor class CardOCR {
  
  struct CardObservation {
    let card: Card
    let observation: VNRectangleObservation //TODO: Maybe just bounding box?
  }
  
  var observations: [CardObservation] = []
  
  //TODO: Replace with https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
  private func performTextRecognition(on image: UIImage) async throws -> [VNRecognizedTextObservation] {
    return try await withCheckedThrowingContinuation { continuation in
      guard let cgImage = image.cgImage else {
        continuation.resume(returning: [])
        return
      }
      
      let request = VNRecognizeTextRequest { request, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
          continuation.resume(returning: [])
          return
        }
        
        continuation.resume(returning: observations)
      }
      
      request.recognitionLevel = .accurate
      let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
      do {
        try handler.perform([request])
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
  
  func perform(with context: ModelContext, on image: UIImage) async {
    observations.removeAll()
    do {
      let rectangeObservations = try await performTextRecognition(on: image)
      
      for observation in rectangeObservations {
        guard let topCandidate = observation.topCandidates(1).first?.string else { continue }
      
        
        let descriptor = FetchDescriptor<Card>(
          predicate: #Predicate<Card> { card in
            card.name.localizedStandardContains(topCandidate)
          }
        )
        
        let possibleCards = try context.fetch(descriptor)
        
        struct ScoredCard {
          let score: Int
          let card: Card
        }
        
        let scoredCard = possibleCards
          .map { ScoredCard(score: $0.name.levenshteinDistance(to: topCandidate), card: $0) }
          .filter { $0.score <= 3 }
          .sorted(using: SortDescriptor(\ScoredCard.score))
          .first
        
        guard let scoredCard else { continue }
        observations.append(CardObservation(card: scoredCard.card, observation: observation))
      }
      
    } catch {
      print(error)
    }
  }
}

struct Box: Shape {
  private let normalizedRect: CGRect
  
  init(observation: VNRectangleObservation) {
    normalizedRect = observation.boundingBox
  }
  
  func path(in rect: CGRect) -> Path {
    let transformedRect = CGRect(
      x: normalizedRect.origin.x * rect.width,
      y: (1 - normalizedRect.origin.y - normalizedRect.height) * rect.height,
      width: normalizedRect.size.width * rect.width,
      height: normalizedRect.size.height * rect.height
    )
    
    // Create a Path for the box
    return Path(transformedRect)
  }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
  DeckScanner()
}
