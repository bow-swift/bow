///  * [Semigroupal]s are associative under the bijection `f = (a,(b,c)) -> ((a,b),c)` or `f = ((a,b),c) -> (a,(b,c))`.
public protocol Semigroupal {
	/// Multiplicatively combine F<A> and F<B> into F<(A, B)>
	static func product<A, B>(_ x: Kind<Self, A>, _ y: Kind<Self, B>) -> Kind<Self, Tuple2<A, B>>
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
	func product<B>(_ y: Kind<F, B>) -> Kind<F, Tuple2<A, B>> {
		F.product(self, y)
	}
	
	/// Add support for the * syntax
	static func * <A, B>(_ x: Kind<F, A>, _ y: Kind<F, B>) -> Kind<F, Tuple2<A, B>> {
		F.product(x, y)
	}
}
