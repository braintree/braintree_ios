import Foundation

struct CVVCharacter: Identifiable {
    
    let id = UUID()
    let value: Character
    var isMasked: Bool = false
}
