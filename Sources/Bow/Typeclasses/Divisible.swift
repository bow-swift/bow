/// Divisible extends Divide by providing an empty value.
public protocol Divisible: Divide {
    /// Provides an empty value for this Divisible instance
    static func conquer<A>() -> Kind<Self, A>
}

// MARK: Syntax for Divisible
public extension Kind where F: Divisible {
    /// Provides an empty value for this Divisible instance
    static func conquer() -> Kind<F, A> {
        F.conquer()
    }
}
