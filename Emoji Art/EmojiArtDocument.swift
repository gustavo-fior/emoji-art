import SwiftUI
// this is for UTType
import UniformTypeIdentifiers

extension UTType {
    
    // creating a custom UTType for our documents
    static let emojiart = UTType(exportedAs: "fior.gustavo.emojiart")
}

// ViewModel
class EmojiArtDocument: ObservableObject, ReferenceFileDocument {
    
    // MARK: - functions for ReferenceFileDocument
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            // if background changed
            if (emojiArt.background != oldValue.background) {
                
                // throw task in another thread
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    init() {
        
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    //    old implementation
    //    var background: URL? {
    //        emojiArt.background
    //    }
    
    @Published var background: Background = .none
    
    // MARK: - Background Image
    
    @MainActor
    private func fetchBackgroundImage() async  {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImageFromURL(from: url)
                
                // checking to make sure the user didn't choose another background in the meantime
                if url == emojiArt.background {
                    background = .found(image)
                }
                
            } catch {
                background = .failed("Couldn't set background: " + error.localizedDescription)
            }
            
            
        } else {
            background = .none
        }
    }
    
    private func fetchUIImageFromURL(from url: URL) async throws -> UIImage {
        
        // get the data from a URL
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let uiImage = UIImage(data: data) {
            return uiImage;
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
    
    // MARK: - Intents
    
    // UNDO and REDO
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    func setBackground(_ url: URL?, undoManager: UndoManager? = nil) {
        undoablyPerform("Set Background", with: undoManager) {
            emojiArt.background = url;
        }
        
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat, undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
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
