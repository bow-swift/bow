import Bow

/// `Cons` provides a `Prism` between this structure and a pair containing its first element and its tail. It provides a convenient way to attach or detach elements to the left side of a structure.
public protocol Cons {
    associatedtype First
    
    /// Provides a `Prism` between this structure and its first element and tail.
    static var cons: Prism<Self, (First, Self)> { get }
}

// MARK: Related functions
public extension Cons {
    /// Provides an `Optional` between this structure and its first element.
    static var firstOption: Optional<Self, First> {
        return cons + Tuple2._0
    }
    
    /// Provides an `Optional` between this structure and its tail.
    static var tailOption: Optional<Self, Self> {
        return cons + Tuple2._1
    }
    
    /// Pre-composes the cons `Prism` with a given isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A prism that provides the first element and tail in another structure resulting from transforming this structure with the provided isomorphism.
    static func cons<B>(_ iso: Iso<B, Self>) -> Prism<B, (First, B)> {
        return iso + cons + iso.reverse().second()
    }
    
    /// Post-composes the cons `Prismp  with a given isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A prism that provides the first element and tail of this structure, where the element has been transformed with the provided isomorphism.
    static func cons<B>(_ iso: Iso<First, B>) -> Prism<Self, (B, Self)> {
        return cons + iso.first()
    }
    
    /// Prepends an element at the left of this structure.
    ///
    /// - Parameter a: Element to prepend.
    /// - Returns: A new structure where the provided element is at the initial position.
    func prepend(_ a: First) -> Self {
        return Self.cons.reverseGet((a, self))
    }
    
    /// Deconstructs this structure into an optional tuple of its first element and its tail.
    var uncons: Option<(First, Self)> {
        return Self.cons.getOption(self)
    }
}
