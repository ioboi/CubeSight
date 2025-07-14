import SwiftData
import SwiftUI

struct ArchetypeSearchResults<Content: View>: View {
  @Query private var archetypes: [DeckArchetype]
  private let content: (DeckArchetype) -> Content

  init(
    searchTerm: String,
    fetchLimit: Int? = nil,
    @ViewBuilder content: @escaping (DeckArchetype) -> Content
  ) {
    self.content = content

    let searchTerm = searchTerm
    let predicate = #Predicate<DeckArchetype> {
      searchTerm.isEmpty || $0.name.localizedStandardContains(searchTerm)
    }
    var descriptor = FetchDescriptor(
      predicate: predicate,
      sortBy: [SortDescriptor(\DeckArchetype.name)]
    )
    if let fetchLimit {
      descriptor.fetchLimit = fetchLimit
    }
    _archetypes = Query(descriptor)
  }

  var body: some View {
    ForEach(archetypes, content: content)
  }
}

#Preview(traits: .sampleData) {
  List {
    ArchetypeSearchResults(searchTerm: "") { archetype in
      Text(archetype.name)
    }
  }
}
