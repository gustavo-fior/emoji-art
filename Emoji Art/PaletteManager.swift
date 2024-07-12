import SwiftUI

struct PaletteManager: View {
    // this is bad practice (we should only access variables with @ObservableObject or @EnvironmentObject)
    let stores: [PaletteStore]
    
    @State private var selectedStore: PaletteStore?
    
    var body: some View {
        // navigation for ipad (3 views)
        NavigationSplitView {
            // selection parameter is what is currently selected
            List(stores, selection: $selectedStore) { store in
                Text(store.name)
                // this is what is selected in $selectedStore
                    .tag(store)
            }
        } content : {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            } else {
                Text("Choose a store")
            }
        } detail: {
            Text("Choose a palette")
        }
    }
}
