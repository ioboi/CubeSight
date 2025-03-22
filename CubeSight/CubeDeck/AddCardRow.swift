import SwiftUI

struct AddCardRow: View {
  var body: some View {
    HStack {
      Image(systemName: "plus")
      Text("Add cards")
    }
    .bold()
  }
}

#Preview {
  List {
    AddCardRow()
  }
}
