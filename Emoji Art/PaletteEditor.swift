//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Gustavo Fior on 10/07/24.
//

import SwiftUI

struct PaletteEditor: View {
    
    // anytime we use this variable, we are using the variable straight out of the view model
    @Binding var palette: Palette
    
    private let emojiFont = Font.system(size: 40)
    
    @State private var emojisToAdd = "";
    
    enum Focused {
        case name
        case addEmojis
    }
    
    // keep track of where the keyboard is focusing
    @FocusState private var focused: Focused?
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                
                // second argument is a binding, so that when this is edited, it changes
                TextField("Name", text: $palette.name)
                    //managing focus
                    .focused($focused, equals: .name)
                    
            }
            Section(header: Text("Emojis")) {
                TextField("Emojis to add", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) {
                        palette.emojis = ($0 + palette.emojis)
                            .filter { $0.isEmoji }
                            .uniqued
                    }
                removeEmojis
            }
        }
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            }
            
            focused = .addEmojis
        }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to remove emojis").font(.caption).foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.remove(emoji.first!)
                                emojisToAdd.remove(emoji.first!)
                            }
                        }
                }
            }
            .font(emojiFont)
        }
    }
}

//#Preview {
//    PaletteEditor(palette: Palette(name: "Preview", emojis: "😀"))
//}
