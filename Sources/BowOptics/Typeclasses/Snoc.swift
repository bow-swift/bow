import Bow

/// `Snoc` defines a `Prism` between this structure and its init (all elements but the last one) and last elements. It can be seen as the reverse of `Cons`. It provides a way to attach or detach elements on the end side of a structure.
public protocol Snoc {
    associatedtype Last
    
    /// Provides a `Prism` between this structure and its init and last element.
    static var snoc: Prism<Self, (Self, Last)> { get }
}

// MARK: Related functions
public extension Snoc {
    /// Provides an `Optional` between this structure and its initial part (all elements but the last one).
    static var initialOption: Optional<Self, Self> {
        return snoc + Tuple2._0
    }
    
    /// Provides an `Optional` between this structure and its last element.
    static var lastOption: Optional<Self, Last> {
        return snoc + Tuple2._1
    }
    
    /// Pre-composes the `Prism` provided by this `Snoc` with an isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A `Prism` between an structure that is isomorphic to this one and its init and last element.
    static func snoc<B>(_ iso: Iso<B, Self>) -> Prism<B, (B, Last)> {
        return iso + snoc + iso.reverse().first()
    }
    
    /// Post-composes the `Prism` provided by this `Snoc` with an isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A `Prism` between this structure and a new foci that is isomorphic to the original one.
    static func snoc<B>(_ iso: Iso<Last, B>) -> Prism<Self, (Self, B)> {
        return snoc + iso.second()
    }
    
    /// Retrieves the initial part of this structure (all elements but the last one).
    var initial: Option<Self> {
        return Self.initialOption.getOption(self)
    }
    
    /// Retrieves the last element of this structure.
    var last: Option<Last> {
        return Self.lastOption.getOption(self)
    }
    
    /// Appends an element at the end of this structure.
    ///
    /// - Parameter a: Element to append.
    /// - Returns: A new structure with the provided element at the end.
    func append(_ a: Last) -> Self {
        return Self.snoc.reverseGet((self, a))
    }
    
    /// Deconstructs this structure into its initial part (all elements but the last one) and its last element.
    var unsnoc: Option<(Self, Last)> {
        return Self.snoc.getOption(self)
    }
}
