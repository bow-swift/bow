import Foundation
import Bow

// MARK: Optics extensions
public extension String {
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<String, Character> {
        return StringTraversal()
    }
}

// MARK: Instance of `Each` for String
extension String: Each {
    public typealias EachFoci = Character
    
    public static var each: Traversal<String, Character> {
        return traversal
    }
}

// MARK: Instance of `Index` for String
extension String: Index {
    public typealias IndexType = Int
    public typealias IndexFoci = Character
    
    public static func index(_ i: Int) -> Optional<String, Character> {
        return Array<Character>.index(i, iso: String.toArray)
    }
}

// MARK: Instance of `FilterIndex` for String
extension String: FilterIndex {
    public typealias FilterIndexType = Int
    public typealias FilterIndexFoci = Character
    
    public static func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<String, Character> {
        return Array<Character>.filter(predicate, iso: String.toArray)
    }
}

// MARK: Instance of `Cons` for String
extension String: Cons {
    public typealias First = Character
    
    public static var cons: Prism<String, (Character, String)> {
        return Array<Character>.cons(String.toArray)
    }
}

// MARK: Instace of `Snoc` for String
extension String: Snoc {
    public typealias Last = Character
    
    public static var snoc: Prism<String, (String, Character)> {
        return Array<Character>.snoc(String.toArray)
    }
}

private class StringTraversal: Traversal<String, Character> {
    override func modifyF<F: Applicative>(_ s: String, _ f: @escaping (Character) -> Kind<F, Character>) -> Kind<F, String> {
        return F.map(s.map(id).k().traverse(f), { x in
            String(ArrayK.fix(x).asArray)
        })
    }
}
