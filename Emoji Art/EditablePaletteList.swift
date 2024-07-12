//
//  PaletteList.swift
//  Emoji Art
//
//  Created by Gustavo Fior on 10/07/24.
//

import SwiftUI

struct EditablePaletteList: View {
    
    @ObservedObject var store: PaletteStore
    
    @State private var showCursorPalette = false
    
    var body: some View {
        // root for navigation
        
        List {
            ForEach(store.palettes) { palette in
                // wrap around what will trigger the navigation
                NavigationLink(value: palette.id) {
                    
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        
                        // only one line (or ...)
                        Text(palette.emojis).lineLimit(1)
                    }
                }
            }
            // index set is a set with all the indices that were swiped
            .onDelete{ indexSet in
                withAnimation {
                    store.palettes.remove(atOffsets: indexSet)
                }
            }
            .onMove { indexSet, newOffset in
                store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
            }
            
        }
        // always outside of list
        .navigationDestination(for: Palette.ID.self) { paletteId in
            // doing this because we have to pass a binding to the PaletteEditor
            if let index = store.palettes.firstIndex(where: { $0.id == paletteId }) {
                PaletteEditor(palette: $store.palettes[index])
            }
        }
        .navigationDestination(isPresented: $showCursorPalette ) {
            PaletteEditor(palette: $store.palettes[store.cursorIndex])
        }
        .navigationTitle(store.name + " Palettes")
        .toolbar {
            Button {
                store.insert(name: "", emojis: "")
                showCursorPalette = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
}

struct PaletteView: View {
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: 300))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
}

