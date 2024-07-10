import Foundation

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalettes
        } else {
            return []
        }
    }
    
    func set(_ palletes: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palletes)
        set(data, forKey: key)
    }
}

// View Model #2 - for Palettes
class PaletteStore: ObservableObject {
    
    let name: String
    
    private var userDefaultsKey: String { "PaletteStore: " + name}
    
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(forKey: userDefaultsKey)
            
        }
        set {
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                // in this property, instead of @Published, we need to alert the view directly
                objectWillChange.send()
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        
        if palettes.isEmpty {
            self.palettes = Palette.builtins
        }
    }
    
    @Published private var _cursorIndex = 0;
    
    var cursorIndex: Int {
        get { boundsCheckPaletteIndex(_cursorIndex) }
        set { _cursorIndex = boundsCheckPaletteIndex(newValue) }
    }
    
    // func that checks for inex out of bounds exceptions
    private func boundsCheckPaletteIndex(_ index: Int) -> Int {
        var index = index % palettes.count
        
        if index < 0 {
            index += palettes.count
        }
        
        return index;
    }
    
    // MARK: - Adding Palettes
    
    // these functions are the recommended way to add Palettes to the PaletteStore
    // since they try to avoid duplication of Identifiable-ly identical Palettes
    // by first removing/replacing any Palette with the same id that is already in palettes
    // it does not "remedy" existing duplication, it just does not "cause" new duplication
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
        let insertionIndex = boundsCheckPaletteIndex(insertionIndex ?? cursorIndex)
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) { // at end of palettes
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
                palettes.append(palette)
            }
        } else {
            palettes.append(palette)
        }
    }
    
    func append(name: String, emojis: String) {
        append(Palette(name: name, emojis: emojis))
    }
}
