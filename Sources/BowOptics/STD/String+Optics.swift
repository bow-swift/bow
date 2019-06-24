import Foundation
import Bow

// MARK: Optics extensions
public extension String {
    /// Provides an Iso between String and Array of Character.
    static var toArray: Iso<String, [Character]> {
        return Iso<String, [Character]>(
            get: { str in str.map(id) },
            reverseGet: { characters in String(characters) })
    }

    /// Provides an Iso between String and ArrayK of Character.
    static var toArrayK: Iso<String, ArrayK<Character>> {
        return String.toArray + Array.toArrayK
    }
}
