import SwiftUI

struct SelectedCardsView: View {
  @Binding var selection: Set<Card>
  @State var editedSelection: Set<Card> = []
  @Environment(\.dismiss) var dismiss: DismissAction

  private var title: String {
    "\(editedSelection.count) Cards Selected"
  }

  private var selectionButtonTitle: String {
    if editedSelection.isEmpty {
      return "Select All"
    } else {
      return "Deselect All"
    }
  }

  var body: some View {
    NavigationStack {
      List(selection: $editedSelection) {
        ForEach(selection.sorted(by: { $0.name < $1.name })) { card in
          CardArtCropRow(card: card)
            .tag(card)
        }
      }
      .environment(\.editMode, .constant(.active))
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(title)
            .bold()
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Done", action: done)
        }
        ToolbarItem(placement: .bottomBar) {
          Button(selectionButtonTitle, action: selectOrDeselectAll)
        }
      }
      .onAppear {
        editedSelection = selection
      }
    }
  }

  private func done() {
    selection = editedSelection
    dismiss()
  }

  private func selectOrDeselectAll() {
    if editedSelection.isEmpty {
      editedSelection = selection
    } else {
      editedSelection.removeAll()
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @State var selection: Set<Card> = [.blackLotus]
  SelectedCardsView(selection: $selection)
}
