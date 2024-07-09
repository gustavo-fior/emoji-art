//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Gustavo Fior on 27/06/24.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
            // inject the object paletteStore in all views
            // great when something is using globally
                .environmentObject(paletteStore)
        }
    }
}
