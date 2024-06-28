import SwiftUI

// ViewModel
class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    private var emojiArt = EmojiArt()
    
    init() {
        emojiArt.addEmoji("🧑‍🧑‍🧒‍🧒", at: .init(x: -200, y: -150), size: 120)
        emojiArt.addEmoji("🥳", at: .init(x: -250, y: 150), size: 212)
        emojiArt.addEmoji("🙊", at: .init(x: 200, y: -50), size: 22)
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
