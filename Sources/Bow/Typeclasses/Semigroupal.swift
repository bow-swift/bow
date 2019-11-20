/// The Semigroupal type class for a given type `F` can be seen as an abstraction over the [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product).
/// It defines the function product.
///
/// The product function for a given type `F`, `A` and `B` combines a `Kind<F, A>` and a `Kind<F, B>` into a `Kind<F, (A, B)>`.
/// This function guarantees compliance with the following laws:
///
/// Semigroupals are associative under the bijection `f = (a,(b,c)) -> ((a,b),c)` or `f = ((a,b),c) -> (a,(b,c))`.
/// Therefore, the following laws also apply:
///
/// ```swift
/// f((a.product(b)).product(c)) == a.product(b.product(c))
/// ```
///
/// ```swift
/// f(a.product(b.product(c))) == (a.product(b)).product(c)
/// ```
public protocol Semigroupal {
    /// Multiplicatively combine F<A> and F<B> into F<(A, B)>
    /// - Parameters:
    ///   - x: First factor.
    ///   - y: Second factor.
    /// - Returns: Tupled result of combining the values provided by both arguments.
	static func product<A, B>(_ x: Kind<Self, A>, _ y: Kind<Self, B>) -> Kind<Self, (A, B)>
}

// MARK: Syntax for Semigroupal
public extension Kind where F: Semigroupal {
    /// Multiplicatively combine F<A> and F<B> into F<(A, B)>
    ///
    /// This is a convenience method to call `Semigroupal.product` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - y: Right value.
    /// - Returns: Cartesian product of the two values.
	func product<B>(_ y: Kind<F, B>) -> Kind<F, (A, B)> {
		F.product(self, y)
	}
}
