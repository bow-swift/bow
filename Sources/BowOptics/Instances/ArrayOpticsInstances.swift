import Bow
import Foundation

// MARK: Optics extensions
public extension Array {
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Array<Element>, Element> {
        return Array.toArrayK + ArrayK.fold
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Array<Element>, Element> {
        return Array.toArrayK + ArrayK.traversal
    }
}

// MARK: Instance of `Each` for Array
extension Array: Each {
    public typealias EachFoci = Element
    
    public static var each: Traversal<Array<Element>, Element> {
        return traversal
    }
}

// MARK: Instance of `Index` for Array
extension Array: Index {
    public typealias IndexType = Int
    public typealias IndexFoci = Element
    
    public static func index(_ i: Int) -> Optional<Array<Element>, Element> {
        return ArrayK<Element>.index(i, iso: toArrayK)
    }
}

// MARK: Instance of `FilterIndex` for Array
extension Array: FilterIndex {
    public typealias FilterIndexType = Int
    public typealias FilterIndexFoci = Element
    
    public static func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<Array<Element>, Element> {
        return ArrayK<Element>.filter(predicate, iso: toArrayK)
    }
}

// MARK: Instance of `Cons` for Array
extension Array: Cons {
    public typealias First = Element
    
    public static var cons: Prism<Array<Element>, (Element, Array<Element>)> {
        return ArrayK<Element>.cons(toArrayK)
    }
}

// MARK: Instance of `Snoc` for Array
extension Array: Snoc {
    public typealias Last = Element
    
    public static var snoc: Prism<Array<Element>, (Array<Element>, Element)> {
        return ArrayK<Element>.snoc(toArrayK)
    }
}
