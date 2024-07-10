import Foundation

// Model
// Protocol Codable is (Decodable + Encodable)
struct EmojiArt : Codable {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self);
        
        print("Emoji Art: \(String(data: encoded, encoding: .utf8) ?? "nil")")
        
        return encoded
    }
    
    init () {}
    
    init (json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        
        emojis.append(Emoji(id: uniqueEmojiId, string: emoji, position: position, size: size))
    }
    
    struct Emoji: Identifiable, Codable {
        var id: Int
        let string: String
        var position: Position
        var size: Int
        
        struct Position: Codable {
            var x: Int
            var y: Int
            
            // aka Emoji.Position or Position(x:0, y:0)
            static let zero = Self(x: 0, y: 0)
        }
    }
}
