import Foundation
import Bow

public extension String {
    public static func toArray() -> Iso<String, [Character]> {
        return Iso<String, [Character]>(
            get: { str in str.map(id) },
            reverseGet: { characters in String(characters) })
    }
    
    public static func toArrayK() -> Iso<String, ArrayK<Character>> {
        return String.toArray() + Array.toArrayK()
    }
}
