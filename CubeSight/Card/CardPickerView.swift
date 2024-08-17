import SwiftData
import SwiftUI

struct CardPickerView: View {
  let cube: Cube
  @Binding var selection: [Card]

  @State private var searchText: String = ""

  @State private var isPhotosPickerPresented = false

  @Environment(\.dismiss) private var dismiss

  private var pickerTitle: String {
    if selection.isEmpty {
      return "Add cards"
    }
    if selection.count == 1 {
      return "Add 1 card"
    }
    return "Add \(selection.count) cards"
  }

  var body: some View {
    NavigationStack {
      CardPickerCardList(cube: cube, searchText: searchText, selection: $selection)
        .searchable(
          text: $searchText,
          placement: .navigationBarDrawer(displayMode: .always),
          prompt: "Search card"
        )
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(pickerTitle)
              .animation(.none)
          }
          ToolbarItem(placement: .primaryAction) {
            Button {
              isPhotosPickerPresented = true
            } label: {
              Label("Search cards by picture", systemImage: "text.viewfinder")
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              withAnimation {
                dismiss()
              }
            }
          }
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel) {
              // Cancel means current selection should not be added.
              selection.removeAll()
              dismiss()
            }
          }
        }
        .sheet(isPresented: $isPhotosPickerPresented) {
          CardScannerView(cube: cube, selection: $selection)
        }
    }
  }
}

private struct CardPickerCardList: View {
  let cube: Cube
  let searchText: String
  @Binding var selection: [Card]

  @Query(sort: \Card.name, order: .forward) private var cards: [Card]

  init(cube: Cube, searchText: String, selection: Binding<[Card]>) {
    self.cube = cube
    self.searchText = searchText
    self._selection = selection
    let predicate = Card.predicate(cubeId: cube.id, searchText: searchText)
    _cards = Query(filter: predicate, sort: \Card.name, order: .forward)
  }

  var body: some View {
    List {
      ForEach(cards) { card in
        HStack {
          SmallCardRow(card: card)
          Spacer()
          AddRemoveCardButton(card: card, selection: $selection)
        }
      }
    }
  }
}

private struct AddRemoveCardButton: View {
  let card: Card
  @Binding var selection: [Card]

  var body: some View {
    Button {
      withAnimation(.easeInOut) {
        if selection.contains(card) {
          guard let index = selection.firstIndex(of: card) else { return }
          selection.remove(at: index)
        } else {
          selection.append(card)
        }
      }
    } label: {
      Group {
        if selection.contains(card) {
          Label("Remove card from selection", systemImage: "checkmark")
            .labelStyle(.iconOnly)
        } else {
          Label("Add card to selection", systemImage: "plus.circle")
        }
      }
      .labelStyle(.iconOnly)
    }
  }
}

#Preview("CardPickerView") {
  ModelContainerPreview(ModelContainer.sample) {
    CardPickerView(cube: Cube.sampleCube, selection: .constant([]))
  }
}

#Preview("AddRemoveCardButton Add") {
  AddRemoveCardButton(card: Card.blackLotus, selection: .constant([]))
}

#Preview("AddRemoveCardButton Remove") {
  AddRemoveCardButton(card: Card.blackLotus, selection: .constant([Card.blackLotus]))
}
