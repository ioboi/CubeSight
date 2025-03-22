import SwiftUI

struct CardPicker: View {
  let cube: Cube
  @Binding var selection: Set<Card>

  @State private var searchText: String = ""
  @State private var isCardImportPresented: Bool = false
  @State private var isShowSelectedPresented: Bool = false
  @Environment(\.dismiss) var dismiss: DismissAction

  private var showSelectedButton: some View {
    Button(action: showSelectedCards) {
      Text("Show Selected (\(selection.count))")
        .bold()
    }
  }
  
  private func showSelectedCards() {
    isShowSelectedPresented = true
  }
  
  var body: some View {
    NavigationStack {
      List(selection: $selection) {
        CardsSearchResults(cube: cube, searchText: $searchText) { card in
          CardArtCropRow(card: card)
            .tag(card)
        }
      }
      .environment(\.editMode, .constant(.active))
      .searchable(text: $searchText, prompt: "Search for a card...")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", role: .cancel, action: cancel)
        }
        ToolbarItem(placement: .primaryAction) {
          Button(
            "Import cards",
            systemImage: "camera.on.rectangle",
            action: importCards
          )
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Done", action: done)
        }
        ToolbarItem(placement: .bottomBar) {
          if selection.isEmpty {
            Text("Select Cards")
              .bold()
          } else {
            showSelectedButton
          }
        }
      }
      .sheet(isPresented: $isCardImportPresented) {
        CubeCardsImportView(cube: cube, cards: $selection)
      }
      .sheet(isPresented: $isShowSelectedPresented) {
        SelectedCardsView(selection: $selection)
      }
    }
  }

  private func importCards() {
    isCardImportPresented = true
  }

  private func cancel() {
    selection.removeAll()
    dismiss()
  }

  private func done() {
    dismiss()
  }
}

#Preview(traits: .sampleData) {
  @Previewable @State var selection: Set<Card> = []
  CardPicker(cube: .sampleCube, selection: $selection)
}
