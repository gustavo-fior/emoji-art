//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Gustavo Fior on 27/06/24.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var ps1 = PaletteStore(named: "Main")
    
    var body: some Scene {
        // DocumentGroup gives the structure for a files app
        DocumentGroup(newDocument: {
            EmojiArtDocument()
        }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(ps1)
        }
    }
}
