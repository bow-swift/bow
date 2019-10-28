/// Divisible extends Divide by providing an empty value.
public protocol Divisible: Divide {
    /// Provides an empty value for Kind<Self, A>
    static func conquer<A>() -> Kind<Self, A>
}

// MARK: Syntax for Divisible
public extension Kind where F: Divisible {
    static func conquer() -> Kind<F, A> {
        F.conquer()
    }
}
