import SwiftUI

// ViewModel
class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    
    private func autosave() {
        save(to: autosaveURL)
        
        print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            
            try data.write(to: url)
        } catch let error {
            // error here
            print("Error while saving: " + error.localizedDescription)
        }
        
    }
    
    init() {
        
        // restoring the emoji art from the file system
        if let data = try? Data(contentsOf: autosaveURL),
            let autosavedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = autosavedEmojiArt
        }
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intents
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url;
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    // escaping reserved word in to use in function name
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        // the center in the local view
        // .center is an extension
        let center = geometry.frame(in: .local).center
        
        // y is - because the coord system is upside down
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
