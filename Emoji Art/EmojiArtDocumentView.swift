import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document : EmojiArtDocument
    
    private let paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                // bg
                Color.white
            
                documentContents(in: geometry)
                    // zoom (* to animate it)
                    .scaleEffect(zoom * gestureZoom)
                    // panning
                    .offset(pan + gesturePan)
            }
            // implementing the zoom and panning gestures (custom)
            .gesture(panGesture.simultaneously(with: zoomGesture))
            // can only have one type of drop destination per view, so we will create a Transferable that can take the URL of the image and the String of emoji
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan = CGSize.zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan = CGSize.zero
    
    private var zoomGesture: some Gesture {
        // pinching
        MagnificationGesture()
            // this makes it "show" the zooming
            // can only modify gestureState during view update
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom *= inMotionPinchScale
            }
            // this makes it work
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        // panning
        DragGesture()
            // this makes it "show" the zooming
            // can only modify gestureState during view update
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan += value.translation
            }
            // this makes it work
            .onEnded { value in
                // for +=, see extensions
                pan += value.translation
            }
    }
    
    // function to separate the contents that will be moveable
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        // image
        AsyncImage(url: document.background)
        // positioning the image in the 0,0 (center) in the geometry
            .position(Emoji.Position.zero.in(geometry))
        
        // emojis
        ForEach(document.emojis) {emoji in
            Text(emoji.string)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        
        // switching between the type of things that can be dropped
        for sturldata in sturldatas {
            switch sturldata {
                
            case .url(let url):
                document.setBackground(url)
                
                return true
                
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom
                )
                return true
            default:
                break
                
            }
            
            return false
        }
        
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        
        return Emoji.Position(
            x: Int(location.x - center.x - pan.width / zoom),
            y: Int(-(location.y - center.y - pan.width) / zoom)
        )
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
