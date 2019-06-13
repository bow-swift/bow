import Bow

/// Protocol for automatic derivation of Prism optics.
public protocol AutoPrism: AutoOptics {}

public extension AutoPrism {
    /// Generates a prism for an enum case with no associated values.
    ///
    /// - Parameter case: Case where the Prism must focus.
    /// - Returns: A Prism focusing on the provided case.
    static func prism(for case: Self) -> Prism<Self, ()> {
        return Prism<Self, ()>(getOrModify: { whole in (String(describing: whole) == String(describing: `case`)) ? Either.right(()) : Either.left(whole) },
                               reverseGet: { _ in `case` })
    }
    
    /// Generates a prism for an enum case with associated values.
    ///
    /// - Parameters:
    ///   - constructor: Constructor for the case with associated values.
    ///   - matching: Closure that matches the focused case of this prism and returns its associated values.
    /// - Returns: A Prism focusing on the provided case.
    static func prism<A>(for constructor: @escaping (A) -> Self, matching: @escaping (Self) -> A?) -> Prism<Self, A> {
        return prism(for: constructor, matching: matching >>> Option.fromOptional)
    }
    
    private static func prism<A>(for constructor: @escaping (A) -> Self, matching: @escaping (Self) -> Option<A>) -> Prism<Self, A> {
        return Prism<Self, A>(getOrModify: { whole in matching(whole).fold({ Either.left(whole) }, Either.right) },
                              reverseGet: constructor)
    }
}
