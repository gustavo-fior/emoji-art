//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Gustavo Fior on 27/06/24.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    
    
    var body: some Scene {
        // DocumentGroup gives the structure for a files app
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
        }
    }
}
