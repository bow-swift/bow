/// Divide is a typeclass that models the divide part of divide and conquer.
///
/// Divide basically states: Given a Kind<F, A> and a Kind<F, B> and a way to turn C into a tuple of A and B it gives you a Kind<F, C>.
///
public protocol Divide: Contravariant {
    /// divide takes two data-types of type Kind<Self, A> and Kind<Self, B> and produces a type of Kind<Self, C> when given
    /// a function from (C) -> (A, B).
    /// - Parameter fa: data of type Kind<Self, A>
    /// - Parameter fb: data of type Kind<Self, B>
    /// - Parameter f: a function to transform C into (A, B)
    /// - Returns: Kind<Self, C>
    static func divide<A, B, C>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ f: (C) -> (A, B)) -> Kind<Self, C>
}

// MARK: Syntax for Divide
public extension Kind where F: Divide {
    /// divide takes a data-type of type Kind<F, B> and produces a type of Kind<F, C> when given
    /// a function from (C) -> (A, B).
    /// - Parameter fb: data of type Kind<F, B>
    /// - Parameter f: a function to transform C into (A, B)
    /// - Returns: Kind<F, C>
    func divide<B, C>(_ fb: Kind<F, B>, _ f: (C) -> (A, B)) -> Kind<F, C> {
        F.divide(self, fb, f)
    }
}
