import Foundation
import Bow

public extension String {
    static var toArray: Iso<String, [Character]> {
        return Iso<String, [Character]>(
            get: { str in str.map(id) },
            reverseGet: { characters in String(characters) })
    }

    static var toArrayK: Iso<String, ArrayK<Character>> {
        return String.toArray + Array.toArrayK
    }
}
