import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store : PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        // this say to the view to stay inside it's bounds (for the emojis to not go up in the animation)
        .clipped()
    }
    
    var chooser : some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu {
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "Math", emojis: "♾️")
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role: .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
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
