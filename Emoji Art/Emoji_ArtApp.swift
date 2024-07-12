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
    @StateObject var ps1 = PaletteStore(named: "Main")
    @StateObject var ps2 = PaletteStore(named: "Second")
    @StateObject var ps3 = PaletteStore(named: "special")
    
    var body: some Scene {
        WindowGroup {
//            EmojiArtDocumentView(document: defaultDocument)
            PaletteManager(stores: [ps1, ps2, ps3])
            // inject the object paletteStore in all views
            // great when something is using globally
                .environmentObject(ps1)
        }
    }
}
