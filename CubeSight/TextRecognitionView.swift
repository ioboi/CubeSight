import SwiftData
import SwiftUI
import Vision

struct BoundingBoxOverlay: View {
  let recognizedText: [(String, VNRectangleObservation)]
  let viewSize: CGSize
  let imageSize: CGSize
  @Binding var selectedText: String?

  var body: some View {
    GeometryReader { geometry in
      let viewFrame = geometry.frame(in: .local)
      let scaleX = viewFrame.width / imageSize.width
      let scaleY = viewFrame.height / imageSize.height
      let scale = min(scaleX, scaleY)

      let imageFrame = CGRect(
        x: (viewFrame.width - imageSize.width * scale) / 2,
        y: (viewFrame.height - imageSize.height * scale) / 2,
        width: imageSize.width * scale,
        height: imageSize.height * scale
      )

      ZStack {
        ForEach(recognizedText, id: \.0) { text, observation in
          let rect = convertRect(observation.boundingBox, to: imageFrame)

          ZStack {
            Rectangle()
              .stroke(text == selectedText ? Color.yellow : Color.red, lineWidth: 2)
              .frame(width: rect.width, height: rect.height)

            Text(text)
              .font(.system(size: 8))
              .padding(2)
              .background(Color.black.opacity(0.7))
              .foregroundColor(.white)
              .cornerRadius(3)
              .offset(y: -rect.height / 2 - 10)
          }
          .position(x: rect.midX, y: rect.midY)
        }
      }
    }
  }

  func convertRect(_ boundingBox: CGRect, to imageFrame: CGRect) -> CGRect {
    let x = boundingBox.minX * imageFrame.width + imageFrame.minX
    let y = (1 - boundingBox.maxY) * imageFrame.height + imageFrame.minY
    let width = boundingBox.width * imageFrame.width
    let height = boundingBox.height * imageFrame.height
    return CGRect(x: x, y: y, width: width, height: height)
  }
}

struct BoundingBoxView: View {
  let image: UIImage
  let recognizedText: [(String, VNRectangleObservation)]
  @Binding var selectedText: String?

  var body: some View {
    GeometryReader { geometry in
      let viewSize = geometry.size

      ZStack {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: viewSize.width, height: viewSize.height)

        BoundingBoxOverlay(
          recognizedText: recognizedText,
          viewSize: viewSize,
          imageSize: image.size,
          selectedText: $selectedText)
      }
    }
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: UIImage?
  @Environment(\.presentationMode) private var presentationMode
  var sourceType: UIImagePickerController.SourceType

  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>)
    -> UIImagePickerController
  {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(
    _ uiViewController: UIImagePickerController,
    context: UIViewControllerRepresentableContext<ImagePicker>
  ) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        parent.selectedImage = image
      }
      parent.presentationMode.wrappedValue.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}

struct TextRecognitionView: View {
  @Query(sort: \Cube.name) private var cubes: [Cube]
  @State private var selectedCubeId: String?
  @State private var selectedImage: UIImage?
  @State private var recognizedText: [(String, VNRectangleObservation)] = []
  @State private var isImagePickerPresented = false
  @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
  @State private var selectedText: String?
  @State private var cardNames: Set<String> = []

  @Environment(\.modelContext) private var modelContext

  var body: some View {
    VStack {
      Picker("Select Cube", selection: $selectedCubeId) {
        Text("All Cubes").tag(String?.none)
        ForEach(cubes) { cube in
          Text(cube.name).tag(String?.some(cube.id))
        }
      }
      .pickerStyle(MenuPickerStyle())
      .padding()
      .onChange(of: selectedCubeId) { _, newValue in
        Task {
          await loadCardNames(for: newValue)
        }
      }

      if let image = selectedImage {
        BoundingBoxView(image: image, recognizedText: recognizedText, selectedText: $selectedText)
          .frame(height: 300)

        List {
          ForEach(recognizedText, id: \.0) { text, _ in
            HStack {
              Text(text)
              Spacer()
              if cardNames.contains(
                where: NSPredicate(format: "SELF CONTAINS[cd] %@", text).evaluate)
              {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
              }
            }
            .onTapGesture {
              selectedText = text
            }
            .background(text == selectedText ? Color.yellow.opacity(0.3) : Color.clear)
          }
        }
      } else {
        Text("Select an image")
          .font(.title)
          .foregroundColor(.gray)
      }

      HStack {
        Button("Choose Photo") {
          sourceType = .photoLibrary
          isImagePickerPresented = true
        }
        .padding()

        Button("Take Photo") {
          sourceType = .camera
          isImagePickerPresented = true
        }
        .padding()
      }
    }
    .sheet(isPresented: $isImagePickerPresented) {
      ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
    }
    .onChange(of: selectedImage) { _, newValue in
      if let image = newValue {
        Task {
          await performTextRecognition(on: image)
        }
      }
    }
    .navigationTitle("Text Recognition")
    .task {
      await loadCardNames(for: selectedCubeId)
    }
  }

  func performTextRecognition(on image: UIImage) async {
    guard let cgImage = image.cgImage else { return }

    let request = VNRecognizeTextRequest { request, error in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

      self.recognizedText = observations.compactMap { observation in
        guard let topCandidate = observation.topCandidates(1).first else { return nil }
        return (topCandidate.string, observation)
      }
    }

    request.recognitionLevel = .accurate

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
    do {
      try handler.perform([request])
    } catch {
      print("Error performing text recognition: \(error)")
    }
  }

  func loadCardNames(for cubeId: String?) async {
    let fetchDescriptor: FetchDescriptor<Card>
    if let cubeId = cubeId {
      fetchDescriptor = FetchDescriptor<Card>(
        predicate: #Predicate {
          $0.mainboards.contains { $0.id == cubeId }
        })
    } else {
      fetchDescriptor = FetchDescriptor<Card>()
    }

    do {
      let cards = try modelContext.fetch(fetchDescriptor)
      cardNames = Set(cards.map { $0.name.lowercased() })
    } catch {
      print("Error fetching cards: \(error)")
    }
  }
}

#Preview {
  TextRecognitionView()
    .modelContainer(for: [Card.self, Cube.self], inMemory: true)
}
