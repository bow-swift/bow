import Foundation

/// An Applicative Functor is a `Functor` that also provides functionality to lift pure expressions, and sequence computations and combine their results.
///
/// Instances of this typeclass must obey the following laws:
///
/// 1. Identity
///
///         ap(pure(id), v) == v
///
/// 2. Composition
///
///         ap(ap(ap(pure(compose), u), v), w) == compose(u, compose(v, w))
///
/// 3. Homomorphism
///
///         ap(pure(f), pure(x)) == pure(f(x))
///
/// 4. Interchange
///
///         ap(fa, pure(b)) == ap(pure({ x in x(a) }), fa)
public protocol Applicative: Functor {
    /// Lifts a value to the context type implementing this instance of `Applicative`.
    ///
    /// - Parameter a: Value to be lifted.
    /// - Returns: Provided value in the context type implementing this instance.
    static func pure<A>(_ a: A) -> Kind<Self, A>

    /// Sequential application.
    ///
    /// - Parameters:
    ///   - ff: A function in the context implementing this instance.
    ///   - fa: A value in the context implementing this instance.
    /// - Returns: A value in the context implementing this instance, resulting of the transformation of the contained original value with the contained function.
    static func ap<A, B>(_ ff: Kind<Self, (A) -> B>, _ fa: Kind<Self, A>) -> Kind<Self, B>
}

// MARK: Related functions
public extension Applicative {
    /// Sequentially compose two computations, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: Result of running the second computation after the first one.
    static func sequenceRight<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, B> {
        return map(fa, fb) { _, b in b }
    }

    /// Sequentially compose two computations, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: Result produced from the first computation after both are computed.
    static func sequenceLeft<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, A> {
        return map(fa, fb) { a, _ in a }
    }

    /// Creates a tuple in the context implementing this instance from two values in the same context.
    ///
    /// - Parameters:
    ///   - fa: 1st value for the tuple.
    ///   - fb: 2nd value for the tuple.
    /// - Returns: A tuple of the provided values in the context implementing this instance.
    static func product<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, (A, B)> {
        return ap(map(fa, { (a: A) in { (b: B) in (a, b) }}), fb)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of two elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, Z>(_ fa: Kind<Self, (A, B)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of three elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, Z>(_ fa: Kind<Self, (A, B, C)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of four elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, D, Z>(_ fa: Kind<Self, (A, B, C, D)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of five elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, D, E, Z>(_ fa: Kind<Self, (A, B, C, D, E)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of six elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, D, E, G, Z>(_ fa: Kind<Self, (A, B, C, D, E, G)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of seven elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, D, E, G, H, Z>(_ fa: Kind<Self, (A, B, C, D, E, G, H)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, H, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, b) })
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A tuple of eight elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<A, B, C, D, E, G, H, I, Z>(_ fa: Kind<Self, (A, B, C, D, E, G, H, I)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, H, I, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, a.7, b) })
    }

    /// Performs two computations in the context implementing this instance and combines their result using the provided function.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    ///   - fb: A lazy value in the context implementing this instance.
    ///   - f: A function to combine the result of the computations.
    /// - Returns: A lazy value with the result of combining the results of each computation.
    static func map2Eval<A, B, Z>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>, _ f: @escaping (A, B) -> Z) -> Eval<Kind<Self, Z>> {
        return Eval.fix(fb.map{ fc in map(fa, fc, f) })
    }

    /// Creates a tuple out of two values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B>(_ a: Kind<Self, A>,
                             _ b : Kind<Self, B>) -> Kind<Self, (A, B)> {
        return product(a, b)
    }

    /// Creates a tuple out of three values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C>(_ a: Kind<Self, A>,
                                _ b: Kind<Self, B>,
                                _ c: Kind<Self, C>) -> Kind<Self, (A, B, C)> {
        return product(product(a, b), c)
    }

    /// Creates a tuple out of four values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D>(_ a: Kind<Self, A>,
                                   _ b: Kind<Self, B>,
                                   _ c: Kind<Self, C>,
                                   _ d: Kind<Self, D>) -> Kind<Self, (A, B, C, D)> {
        return product(product(product(a, b), c), d)
    }

    /// Creates a tuple out of five values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D, E>(_ a: Kind<Self, A>,
                                      _ b: Kind<Self, B>,
                                      _ c: Kind<Self, C>,
                                      _ d: Kind<Self, D>,
                                      _ e: Kind<Self, E>) -> Kind<Self, (A, B, C, D, E)> {
        return product(product(product(product(a, b), c), d), e)
    }

    /// Creates a tuple out of six values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D, E, G>(_ a: Kind<Self, A>,
                                         _ b: Kind<Self, B>,
                                         _ c: Kind<Self, C>,
                                         _ d: Kind<Self, D>,
                                         _ e: Kind<Self, E>,
                                         _ g: Kind<Self, G>) -> Kind<Self, (A, B, C, D, E, G)> {
        return product(product(product(product(product(a, b), c), d), e), g)
    }

    /// Creates a tuple out of seven values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D, E, G, H>(_ a: Kind<Self, A>,
                                            _ b: Kind<Self, B>,
                                            _ c: Kind<Self, C>,
                                            _ d: Kind<Self, D>,
                                            _ e: Kind<Self, E>,
                                            _ g: Kind<Self, G>,
                                            _ h: Kind<Self, H>) -> Kind<Self, (A, B, C, D, E, G, H)> {
        return product(product(product(product(product(product(a, b), c), d), e), g), h)
    }

    /// Creates a tuple out of eight values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    ///   - i: 8th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D, E, G, H, I>(_ a: Kind<Self, A>,
                                               _ b: Kind<Self, B>,
                                               _ c: Kind<Self, C>,
                                               _ d: Kind<Self, D>,
                                               _ e: Kind<Self, E>,
                                               _ g: Kind<Self, G>,
                                               _ h: Kind<Self, H>,
                                               _ i: Kind<Self, I>) -> Kind<Self, (A, B, C, D, E, G, H, I)> {
        return product(product(product(product(product(product(product(a, b), c), d), e), g), h), i)
    }

    /// Creates a tuple out of nine values in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    ///   - i: 8th value of the tuple.
    ///   - j: 9th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<A, B, C, D, E, G, H, I, J>(_ a: Kind<Self, A>,
                                                  _ b: Kind<Self, B>,
                                                  _ c: Kind<Self, C>,
                                                  _ d: Kind<Self, D>,
                                                  _ e: Kind<Self, E>,
                                                  _ g: Kind<Self, G>,
                                                  _ h: Kind<Self, H>,
                                                  _ i: Kind<Self, I>,
                                                  _ j: Kind<Self, J>) -> Kind<Self, (A, B, C, D, E, G, H, I, J)> {
        return product(product(product(product(product(product(product(product(a, b), c), d), e), g), h), i), j)
    }

    /// Combines the result of two computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, Z>(_ a: Kind<Self, A>,
                             _ b: Kind<Self, B>,
                             _ f: @escaping (A, B) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b), f)
    }

    /// Combines the result of three computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, Z>(_ a: Kind<Self, A>,
                                _ b: Kind<Self, B>,
                                _ c: Kind<Self, C>,
                                _ f: @escaping (A, B, C) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c), f)
    }

    /// Combines the result of four computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, Z>(_ a: Kind<Self, A>,
                                   _ b: Kind<Self, B>,
                                   _ c: Kind<Self, C>,
                                   _ d: Kind<Self, D>,
                                   _ f: @escaping (A, B, C, D) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d), f)
    }

    /// Combines the result of five computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, Z>(_ a: Kind<Self, A>,
                                      _ b: Kind<Self, B>,
                                      _ c: Kind<Self, C>,
                                      _ d: Kind<Self, D>,
                                      _ e: Kind<Self, E>,
                                      _ f: @escaping (A, B, C, D, E) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d, e), f)
    }

    /// Combines the result of six computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, Z>(_ a: Kind<Self, A>,
                                         _ b: Kind<Self, B>,
                                         _ c: Kind<Self, C>,
                                         _ d: Kind<Self, D>,
                                         _ e: Kind<Self, E>,
                                         _ g: Kind<Self, G>,
                                         _ f: @escaping (A, B, C, D, E, G) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d, e, g), f)
    }

    /// Combines the result of seven computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, Z>(_ a: Kind<Self, A>,
                                            _ b: Kind<Self, B>,
                                            _ c: Kind<Self, C>,
                                            _ d: Kind<Self, D>,
                                            _ e: Kind<Self, E>,
                                            _ g: Kind<Self, G>,
                                            _ h: Kind<Self, H>,
                                            _ f: @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d, e, g, h), f)
    }

    /// Combines the result of eight computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - i: 8th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, I, Z>(_ a: Kind<Self, A>,
                                               _ b: Kind<Self, B>,
                                               _ c: Kind<Self, C>,
                                               _ d: Kind<Self, D>,
                                               _ e: Kind<Self, E>,
                                               _ g: Kind<Self, G>,
                                               _ h: Kind<Self, H>,
                                               _ i: Kind<Self, I>,
                                               _ f: @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d, e, g, h, i), f)
    }

    /// Combines the result of nine computations in the context implementing this instance, using the provided function.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - i: 8th computation.
    ///   - j: 9th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, I, J, Z>(_ a: Kind<Self, A>,
                                                  _ b: Kind<Self, B>,
                                                  _ c: Kind<Self, C>,
                                                  _ d: Kind<Self, D>,
                                                  _ e: Kind<Self, E>,
                                                  _ g: Kind<Self, G>,
                                                  _ h: Kind<Self, H>,
                                                  _ i: Kind<Self, I>,
                                                  _ j: Kind<Self, J>,
                                                  _ f: @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<Self, Z> {
        return map(zip(a, b, c, d, e, g, h, i, j), f)
    }
}

// MARK: Syntax for Applicative
public extension Kind where F: Applicative {
    /// Lifts a value to the context type implementing this instance of `Applicative`.
    ///
    /// This is a convenience method to call `Applicative.pure` as a static method of this type.
    ///
    /// - Parameter a: Value to be lifted.
    /// - Returns: Provided value in the context type implementing this instance.
    static func pure(_ a: A) -> Kind<F, A> {
        return F.pure(a)
    }

    /// Sequential application.
    ///
    /// This is a convenience method to call `Applicative.ap` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    /// - Returns: A value in the context implementing this instance, resulting of the transformation of the contained original value with the contained function.
    func ap<AA, B>(_ fa: Kind<F, AA>) -> Kind<F, B> where A == (AA) -> B {
        return F.ap(self, fa)
    }

    /// Creates a tuple in the context implementing this instance from two values in the same context.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: 1st value for the tuple.
    ///   - fb: 2nd value for the tuple.
    /// - Returns: A tuple of the provided values in the context implementing this instance.
    static func product<AA, B>(_ fa: Kind<F, AA>, _ fb: Kind<F, B>) -> Kind<F, (AA, B)> where A == (AA, B) {
        return F.product(fa, fb)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of two elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, Z>(_ fa: Kind<F, (AA, B)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, Z)> where A == (AA, B, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of three elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, Z>(_ fa: Kind<F, (AA, B, C)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, C, Z)> where A == (AA, B, C, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of four elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, D, Z>(_ fa: Kind<F, (AA, B, C, D)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, C, D, Z)> where A == (AA, B, C, D, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of five elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, D, E, Z>(_ fa: Kind<F, (AA, B, C, D, E)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, C, D, E, Z)> where A == (AA, B, C, D, E, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of six elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, D, E, G, Z>(_ fa: Kind<F, (AA, B, C, D, E, G)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, C, D, E, G, Z)> where A == (AA, B, C, D, E, G, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of seven elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, D, E, G, H, Z>(_ fa: Kind<F, (AA, B, C, D, E, G, H)>, _ fz: Kind<F, Z>) -> Kind<F, (AA, B, C, D, E, G, H, Z)> where A == (AA, B, C, D, E, G, H, Z) {
        return F.product(fa, fz)
    }

    /// Adds an element to the right of a tuple in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.product` as a static method of this type.
    ///
    /// - Parameters:
    ///   - fa: A tuple of eight elements in the context implementing this instance.
    ///   - fz: A value in the context implementing this instance.
    /// - Returns: A tuple with the value of the second argument added to the right of the tuple, in the context implementing this instance.
    static func product<AA, B, C, D, E, G, H, I, Z>(_ fa: Kind<F, (AA, B, C, D, E, G, H, I)>, _ fz : Kind<F, Z>) -> Kind<F, (AA, B, C, D, E, G, H, I, Z)> where A == (AA, B, C, D, E, G, H, I, Z) {
        return F.product(fa, fz)
    }

    /// Creates a tuple out of two values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B>(_ a: Kind<F, AA>,
                           _ b : Kind<F, B>) -> Kind<F, (AA, B)> where A == (AA, B){
        return F.zip(a, b)
    }

    /// Creates a tuple out of three values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C>(_ a: Kind<F, AA>,
                              _ b: Kind<F, B>,
                              _ c: Kind<F, C>) -> Kind<F, (AA, B, C)> where A == (AA, B, C) {
        return F.zip(a, b, c)
    }

    /// Creates a tuple out of four values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D>(_ a: Kind<F, AA>,
                                 _ b: Kind<F, B>,
                                 _ c: Kind<F, C>,
                                 _ d: Kind<F, D>) -> Kind<F, (AA, B, C, D)> where A == (AA, B, C, D) {
        return F.zip(a, b, c, d)
    }

    /// Creates a tuple out of five values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D, E>(_ a: Kind<F, AA>,
                                    _ b: Kind<F, B>,
                                    _ c: Kind<F, C>,
                                    _ d: Kind<F, D>,
                                    _ e: Kind<F, E>) -> Kind<F, (AA, B, C, D, E)> where A == (AA, B, C, D, E) {
        return F.zip(a, b, c, d, e)
    }

    /// Creates a tuple out of six values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D, E, G>(_ a: Kind<F, AA>,
                                       _ b: Kind<F, B>,
                                       _ c: Kind<F, C>,
                                       _ d: Kind<F, D>,
                                       _ e: Kind<F, E>,
                                       _ g: Kind<F, G>) -> Kind<F, (AA, B, C, D, E, G)> where A == (AA, B, C, D, E, G) {
        return F.zip(a, b, c, d, e, g)
    }

    /// Creates a tuple out of seven values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D, E, G, H>(_ a: Kind<F, AA>,
                                          _ b: Kind<F, B>,
                                          _ c: Kind<F, C>,
                                          _ d: Kind<F, D>,
                                          _ e: Kind<F, E>,
                                          _ g: Kind<F, G>,
                                          _ h: Kind<F, H>) -> Kind<F, (AA, B, C, D, E, G, H)> where A == (AA, B, C, D, E, G, H) {
        return F.zip(a, b, c, d, e, g, h)
    }

    /// Creates a tuple out of eight values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    ///   - i: 8th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D, E, G, H, I>(_ a: Kind<F, AA>,
                                             _ b: Kind<F, B>,
                                             _ c: Kind<F, C>,
                                             _ d: Kind<F, D>,
                                             _ e: Kind<F, E>,
                                             _ g: Kind<F, G>,
                                             _ h: Kind<F, H>,
                                             _ i: Kind<F, I>) -> Kind<F, (AA, B, C, D, E, G, H, I)> where A == (AA, B, C, D, E, G, H, I) {
        return F.zip(a, b, c, d, e, g, h, i)
    }

    /// Creates a tuple out of nine values in the context implementing this instance.
    ///
    /// This is a convenience method to call `Applicative.zip` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - g: 6th value of the tuple.
    ///   - h: 7th value of the tuple.
    ///   - i: 8th value of the tuple.
    ///   - j: 9th value of the tuple.
    /// - Returns: A tuple in the context implementing this instance.
    static func zip<AA, B, C, D, E, G, H, I, J>(_ a: Kind<F, AA>,
                                                _ b: Kind<F, B>,
                                                _ c: Kind<F, C>,
                                                _ d: Kind<F, D>,
                                                _ e: Kind<F, E>,
                                                _ g: Kind<F, G>,
                                                _ h: Kind<F, H>,
                                                _ i: Kind<F, I>,
                                                _ j: Kind<F, J>) -> Kind<F, (AA, B, C, D, E, G, H, I, J)> where A == (AA, B, C, D, E, G, H, I, J) {
        return F.zip(a, b, c, d, e, g, h, i, j)
    }

    /// Combines the result of two computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, Z>(_ a: Kind<F, Z>,
                             _ b: Kind<F, B>,
                             _ f: @escaping (Z, B) -> A) -> Kind<F, A> {
        return F.map(a, b, f)
    }

    /// Combines the result of three computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, Z>(_ a: Kind<F, Z>,
                                _ b: Kind<F, B>,
                                _ c: Kind<F, C>,
                                _ f: @escaping (Z, B, C) -> A) -> Kind<F, A> {
        return F.map(a, b, c, f)
    }

    /// Combines the result of four computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, Z>(_ a: Kind<F, Z>,
                                   _ b: Kind<F, B>,
                                   _ c: Kind<F, C>,
                                   _ d: Kind<F, D>,
                                   _ f: @escaping (Z, B, C, D) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, f)
    }

    /// Combines the result of five computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, Z>(_ a: Kind<F, Z>,
                                      _ b: Kind<F, B>,
                                      _ c: Kind<F, C>,
                                      _ d: Kind<F, D>,
                                      _ e: Kind<F, E>,
                                      _ f: @escaping (Z, B, C, D, E) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, e, f)
    }

    /// Combines the result of six computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, Z>(_ a: Kind<F, Z>,
                                         _ b: Kind<F, B>,
                                         _ c: Kind<F, C>,
                                         _ d: Kind<F, D>,
                                         _ e: Kind<F, E>,
                                         _ g: Kind<F, G>,
                                         _ f: @escaping (Z, B, C, D, E, G) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, e, g, f)
    }

    /// Combines the result of seven computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, Z>(_ a: Kind<F, Z>,
                                            _ b: Kind<F, B>,
                                            _ c: Kind<F, C>,
                                            _ d: Kind<F, D>,
                                            _ e: Kind<F, E>,
                                            _ g: Kind<F, G>,
                                            _ h: Kind<F, H>,
                                            _ f: @escaping (Z, B, C, D, E, G, H) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, e, g, h, f)
    }

    /// Combines the result of eight computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - i: 8th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, I, Z>(_ a: Kind<F, Z>,
                                               _ b: Kind<F, B>,
                                               _ c: Kind<F, C>,
                                               _ d: Kind<F, D>,
                                               _ e: Kind<F, E>,
                                               _ g: Kind<F, G>,
                                               _ h: Kind<F, H>,
                                               _ i: Kind<F, I>,
                                               _ f: @escaping (Z, B, C, D, E, G, H, I) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, e, g, h, i, f)
    }

    /// Combines the result of nine computations in the context implementing this instance, using the provided function.
    ///
    /// This is a convenience method to call `Applicative.map` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: 1st computation.
    ///   - b: 2nd computation.
    ///   - c: 3rd computation.
    ///   - d: 4th computation.
    ///   - e: 5th computation.
    ///   - g: 6th computation.
    ///   - h: 7th computation.
    ///   - i: 8th computation.
    ///   - j: 9th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in the context implementing this instance.
    static func map<A, B, C, D, E, G, H, I, J, Z>(_ a: Kind<F, Z>,
                                                  _ b: Kind<F, B>,
                                                  _ c: Kind<F, C>,
                                                  _ d: Kind<F, D>,
                                                  _ e: Kind<F, E>,
                                                  _ g: Kind<F, G>,
                                                  _ h: Kind<F, H>,
                                                  _ i: Kind<F, I>,
                                                  _ j: Kind<F, J>,
                                                  _ f: @escaping (Z, B, C, D, E, G, H, I, J) -> A) -> Kind<F, A> {
        return F.map(a, b, c, d, e, g, h, i, j, f)
    }
}
