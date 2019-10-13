/// The Semigroupal type class for a given type `F` can be seen as an abstraction over the [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product).
/// It defines the function product.
///
/// The product function for a given type `F`, `A` and `B` combines a `Kind<F, A>` and a `Kind<F, B>` into a `Kind<F, Tuple2<A, B>>`.
/// This function guarantees compliance with the following laws:
///
/// [Semigroupal]s are associative under the bijection `f = (a,(b,c)) -> ((a,b),c)` or `f = ((a,b),c) -> (a,(b,c))`.
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
	/// Multiplicatively combine F<A> and F<B> into F<Tuple2<A, B>>
	static func product<A, B>(_ x: Kind<Self, A>, _ y: Kind<Self, B>) -> Kind<Self, Tuple2<A, B>>
}

// MARK: Syntax for Semigroupal
public extension Kind where F: Semigroupal {
    /// Multiplicatively combine F<A> and F<B> into F<Tuple2<A, B>>
    ///
    /// This is a convenience method to call `Semigroupal.product` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - y: Right value.
    /// - Returns: Cartesian product of the two values.
	func product<B>(_ y: Kind<F, B>) -> Kind<F, Tuple2<A, B>> {
		F.product(self, y)
	}
	
	/// Add support for the * syntax
	static func * <A, B>(_ x: Kind<F, A>, _ y: Kind<F, B>) -> Kind<F, Tuple2<A, B>> {
		F.product(x, y)
	}
}
