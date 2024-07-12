import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store : PaletteStore
    
    @State private var showPaletteEditor = false;
    @State private var showPaletteList = false;
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        // this say to the view to stay inside it's bounds (for the emojis to not go up in the animation)
        .clipped()
        .sheet(isPresented: $showPaletteEditor) {
            // passing a bind to an environment object (store)
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
                .font(nil)
        }
        .sheet(isPresented: $showPaletteList) {
            // passing a bind to an environment object (store)
            NavigationStack {
                EditablePaletteList(store: store)
                    .font(nil)
            }
        }
    }
    
    var chooser : some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu {
            goToMenu
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "", emojis: "")
                showPaletteEditor = true;
            }
            AnimatedActionButton("List", systemImage: "list.bullet.rectangle.portrait") {
                showPaletteList = true;
            }
            AnimatedActionButton("Edit", systemImage: "pencil") {
                showPaletteEditor = true;
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
        }
    }
    
    private var goToMenu: some View {
        Menu {
            ForEach(store.palettes) { pallete in
                AnimatedActionButton(pallete.name) {
                    store.cursorIndex = store.palettes.firstIndex(where: {$0.id == pallete.id }) ?? 0
                }
            }
        } label: {
            Label("Go to", systemImage: "text.insert")
        }
    }
    
    func view (for pallete: Palette) -> some View {
        HStack {
            Text(pallete.name)
            ScrollingEmojis(pallete.emojis)
        }
        // this makes this HStack unique, which makes the animation work (it was not working, because only the arguments inside the HStack change, not the HStack itself
        .id(pallete.id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(_ emojis: String) {
        // Calling the string constructor to char -> string
        self.emojis = emojis.uniqued.map(String.init)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
}

#Preview {
    PaletteChooser()
        .environmentObject(PaletteStore(named: "Preview"))
}
