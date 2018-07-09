import Foundation

public extension String {
    public static func toArray() -> Iso<String, [Character]> {
        return Iso<String, [Character]>(
            get: { str in str.map(id) },
            reverseGet: { characters in String(characters) })
    }
    
    public static func toListK() -> Iso<String, ListK<Character>> {
        return String.toArray() + Array.toListK()
    }
}
