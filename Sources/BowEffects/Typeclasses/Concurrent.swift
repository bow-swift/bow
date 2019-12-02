import Foundation
import Bow

/// Concurrent describes asynchronous operations that can be started concurrently.
public protocol Concurrent: Async {
    /// Runs 2 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, Z>(_ fa: Kind<Self, A>,
                                _ fb: Kind<Self, B>,
                                _ f: @escaping (A, B) -> Z) -> Kind<Self, Z>
    
    /// Runs 3 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, Z>(_ fa: Kind<Self, A>,
                                   _ fb: Kind<Self, B>,
                                   _ fc: Kind<Self, C>,
                                   _ f: @escaping (A, B, C) -> Z) -> Kind<Self, Z>
    
    /// Runs 2 computations in parallel and returns the result of the first one finishing.
    ///
    /// - Parameters:
    ///   - fa: 1st computation
    ///   - fb: 2nd computation
    /// - Returns: A computation with the result of the first computation that finished.
    static func race<A, B>(_ fa: Kind<Self, A>,
                           _ fb: Kind<Self, B>) -> Kind<Self, Either<A, B>>
}

// MARK: Related functions

public extension Concurrent {
    /// Runs 2 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B>(_ fa: Kind<Self, A>,
                             _ fb: Kind<Self, B>) -> Kind<Self, (A, B)> {
        return Self.parMap(fa, fb, { a, b in (a, b) })
    }
    
    /// Runs 3 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C>(_ fa: Kind<Self, A>,
                                _ fb: Kind<Self, B>,
                                _ fc: Kind<Self, C>) -> Kind<Self, (A, B, C)> {
        return Self.parMap(fa, fb, fc) { a, b, c in (a, b, c) }
    }
    
    /// Runs 4 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D>(_ fa: Kind<Self, A>,
                                   _ fb: Kind<Self, B>,
                                   _ fc: Kind<Self, C>,
                                   _ fd: Kind<Self, D>) -> Kind<Self, (A, B, C, D)> {
        return Self.parMap(fa, fb, fc, fd, { a, b, c, d in (a, b, c, d) })
    }
    
    /// Runs 5 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D, E>(_ fa: Kind<Self, A>,
                                      _ fb: Kind<Self, B>,
                                      _ fc: Kind<Self, C>,
                                      _ fd: Kind<Self, D>,
                                      _ fe: Kind<Self, E>) -> Kind<Self, (A, B, C, D, E)> {
        return Self.parMap(fa, fb, fc, fd, fe, { a, b, c, d, e in (a, b, c, d, e) })
    }
    
    /// Runs 6 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D, E, G>(_ fa: Kind<Self, A>,
                                         _ fb: Kind<Self, B>,
                                         _ fc: Kind<Self, C>,
                                         _ fd: Kind<Self, D>,
                                         _ fe: Kind<Self, E>,
                                         _ fg: Kind<Self, G>) -> Kind<Self, (A, B, C, D, E, G)> {
        return Self.parMap(fa, fb, fc, fd, fe, fg, { a, b, c, d, e, g in (a, b, c, d, e, g) })
    }
    
    /// Runs 7 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D, E, G, H>(_ fa: Kind<Self, A>,
                                            _ fb: Kind<Self, B>,
                                            _ fc: Kind<Self, C>,
                                            _ fd: Kind<Self, D>,
                                            _ fe: Kind<Self, E>,
                                            _ fg: Kind<Self, G>,
                                            _ fh: Kind<Self, H>) -> Kind<Self, (A, B, C, D, E, G, H)> {
        return Self.parMap(fa, fb, fc, fd, fe, fg, fh, { a, b, c, d, e, g, h in (a, b, c, d, e, g, h) })
    }
    
    /// Runs 8 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D, E, G, H, I>(_ fa: Kind<Self, A>,
                                               _ fb: Kind<Self, B>,
                                               _ fc: Kind<Self, C>,
                                               _ fd: Kind<Self, D>,
                                               _ fe: Kind<Self, E>,
                                               _ fg: Kind<Self, G>,
                                               _ fh: Kind<Self, H>,
                                               _ fi: Kind<Self, I>) -> Kind<Self, (A, B, C, D, E, G, H, I)> {
        return Self.parMap(fa, fb, fc, fd, fe, fg, fh, fi, { a, b, c, d, e, g, h, i in (a, b, c, d, e, g, h, i) })
    }
    
    /// Runs 9 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - fj: 9th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<A, B, C, D, E, G, H, I, J>(_ fa: Kind<Self, A>,
                                                  _ fb: Kind<Self, B>,
                                                  _ fc: Kind<Self, C>,
                                                  _ fd: Kind<Self, D>,
                                                  _ fe: Kind<Self, E>,
                                                  _ fg: Kind<Self, G>,
                                                  _ fh: Kind<Self, H>,
                                                  _ fi: Kind<Self, I>,
                                                  _ fj: Kind<Self, J>) -> Kind<Self, (A, B, C, D, E, G, H, I, J)> {
        return Self.parMap(fa, fb, fc, fd, fe, fg, fh, fi, fj, { a, b, c, d, e, g, h, i, j in (a, b, c, d, e, g, h, i, j) })
    }
    
    /// Runs 4 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, Z>(_ fa: Kind<Self, A>,
                                      _ fb: Kind<Self, B>,
                                      _ fc: Kind<Self, C>,
                                      _ fd: Kind<Self, D>,
                                      _ f: @escaping (A, B, C, D) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, { a, b in (a, b) }),
                           Self.parMap(fc, fd, { c, d in (c, d) }),
                           { x, y in f(x.0, x.1, y.0, y.1) })
    }
    
    /// Runs 5 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, E, Z>(_ fa: Kind<Self, A>,
                                         _ fb: Kind<Self, B>,
                                         _ fc: Kind<Self, C>,
                                         _ fd: Kind<Self, D>,
                                         _ fe: Kind<Self, E>,
                                         _ f: @escaping (A, B, C, D, E) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                           Self.parMap(fd, fe, { d, e in (d, e) }),
                           { x, y in f(x.0, x.1, x.2, y.0, y.1) })
    }
    
    /// Runs 6 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, E, G, Z>(_ fa: Kind<Self, A>,
                                            _ fb: Kind<Self, B>,
                                            _ fc: Kind<Self, C>,
                                            _ fd: Kind<Self, D>,
                                            _ fe: Kind<Self, E>,
                                            _ fg: Kind<Self, G>,
                                            _ f: @escaping (A, B, C, D, E, G) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                           Self.parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                           { x, y in f(x.0, x.1, x.2, y.0, y.1, y.2) })
    }
    
    /// Runs 7 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, E, G, H, Z>(_ fa: Kind<Self, A>,
                                               _ fb: Kind<Self, B>,
                                               _ fc: Kind<Self, C>,
                                               _ fd: Kind<Self, D>,
                                               _ fe: Kind<Self, E>,
                                               _ fg: Kind<Self, G>,
                                               _ fh: Kind<Self, H>,
                                               _ f: @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                           Self.parMap(fd, fe, { d, e in (d, e) }),
                           Self.parMap(fg, fh, { g, h in (g, h) }),
                           { x, y, z in f(x.0, x.1, x.2, y.0, y.1, z.0, z.1) }
        )
    }
    
    /// Runs 8 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, E, G, H, I, Z>(_ fa: Kind<Self, A>,
                                                  _ fb: Kind<Self, B>,
                                                  _ fc: Kind<Self, C>,
                                                  _ fd: Kind<Self, D>,
                                                  _ fe: Kind<Self, E>,
                                                  _ fg: Kind<Self, G>,
                                                  _ fh: Kind<Self, H>,
                                                  _ fi: Kind<Self, I>,
                                                  _ f: @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                           Self.parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                           Self.parMap(fh, fi, { h, i in (h, i) }),
                           { x, y, z in f(x.0, x.1, x.2, y.0, y.1, y.2, z.0, z.1) })
    }
    
    /// Runs 9 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - fj: 9th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<A, B, C, D, E, G, H, I, J, Z>(_ fa: Kind<Self, A>,
                                                     _ fb: Kind<Self, B>,
                                                     _ fc: Kind<Self, C>,
                                                     _ fd: Kind<Self, D>,
                                                     _ fe: Kind<Self, E>,
                                                     _ fg: Kind<Self, G>,
                                                     _ fh: Kind<Self, H>,
                                                     _ fi: Kind<Self, I>,
                                                     _ fj: Kind<Self, J>,
                                                     _ f: @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                           Self.parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                           Self.parMap(fh, fi, fj, { h, i, j in (h, i, j) }),
                           { x, y, z in f(x.0, x.1, x.2, y.0, y.1, y.2, z.0, z.1, z.2) })
    }
}

// MARK: Syntax for Concurrent

public extension Kind where F: Concurrent {
    /// Runs 2 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B>(_ fa: Kind<F, Z>,
                             _ fb: Kind<F, B>) -> Kind<F, (Z, B)> where A == (Z, B) {
        return F.parMap(fa, fb, { a, b in (a, b) })
    }
    
    /// Runs 3 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C>(_ fa: Kind<F, Z>,
                                _ fb: Kind<F, B>,
                                _ fc: Kind<F, C>) -> Kind<F, (Z, B, C)> where A == (Z, B, C) {
        return F.parMap(fa, fb, fc) { a, b, c in (a, b, c) }
    }
    
    /// Runs 4 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D>(_ fa: Kind<F, Z>,
                                   _ fb: Kind<F, B>,
                                   _ fc: Kind<F, C>,
                                   _ fd: Kind<F, D>) -> Kind<F, (Z, B, C, D)> where A == (Z, B, C, D) {
        return F.parMap(fa, fb, fc, fd, { a, b, c, d in (a, b, c, d) })
    }
    
    /// Runs 5 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D, E>(_ fa: Kind<F, Z>,
                                      _ fb: Kind<F, B>,
                                      _ fc: Kind<F, C>,
                                      _ fd: Kind<F, D>,
                                      _ fe: Kind<F, E>) -> Kind<F, (Z, B, C, D, E)> where A == (Z, B, C, D, E) {
        return F.parMap(fa, fb, fc, fd, fe, { a, b, c, d, e in (a, b, c, d, e) })
    }
    
    /// Runs 6 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D, E, G>(_ fa: Kind<F, Z>,
                                         _ fb: Kind<F, B>,
                                         _ fc: Kind<F, C>,
                                         _ fd: Kind<F, D>,
                                         _ fe: Kind<F, E>,
                                         _ fg: Kind<F, G>) -> Kind<F, (Z, B, C, D, E, G)> where A == (Z, B, C, D, E, G) {
        return F.parMap(fa, fb, fc, fd, fe, fg, { a, b, c, d, e, g in (a, b, c, d, e, g) })
    }
    
    /// Runs 7 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D, E, G, H>(_ fa: Kind<F, Z>,
                                            _ fb: Kind<F, B>,
                                            _ fc: Kind<F, C>,
                                            _ fd: Kind<F, D>,
                                            _ fe: Kind<F, E>,
                                            _ fg: Kind<F, G>,
                                            _ fh: Kind<F, H>) -> Kind<F, (Z, B, C, D, E, G, H)> where A == (Z, B, C, D, E, G, H) {
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, { a, b, c, d, e, g, h in (a, b, c, d, e, g, h) })
    }
    
    /// Runs 8 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D, E, G, H, I>(_ fa: Kind<F, Z>,
                                               _ fb: Kind<F, B>,
                                               _ fc: Kind<F, C>,
                                               _ fd: Kind<F, D>,
                                               _ fe: Kind<F, E>,
                                               _ fg: Kind<F, G>,
                                               _ fh: Kind<F, H>,
                                               _ fi: Kind<F, I>) -> Kind<F, (Z, B, C, D, E, G, H, I)> where A == (Z, B, C, D, E, G, H, I) {
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, { a, b, c, d, e, g, h, i in (a, b, c, d, e, g, h, i) })
    }
    
    /// Runs 9 computations in parallel and tuples their results.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - fj: 9th computation.
    /// - Returns: A computation that describes the parallel execution.
    static func parZip<Z, B, C, D, E, G, H, I, J>(_ fa: Kind<F, Z>,
                                                  _ fb: Kind<F, B>,
                                                  _ fc: Kind<F, C>,
                                                  _ fd: Kind<F, D>,
                                                  _ fe: Kind<F, E>,
                                                  _ fg: Kind<F, G>,
                                                  _ fh: Kind<F, H>,
                                                  _ fi: Kind<F, I>,
                                                  _ fj: Kind<F, J>) -> Kind<F, (Z, B, C, D, E, G, H, I, J)> where A == (Z, B, C, D, E, G, H, I, J) {
        F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, fj, { a, b, c, d, e, g, h, i, j in (a, b, c, d, e, g, h, i, j) })
    }
    
    /// Runs 2 computations in parallel and returns the result of the first one finishing.
    ///
    /// - Parameters:
    ///   - fb: 1st computation
    ///   - fc: 2nd computation
    /// - Returns: A computation with the result of the first computation that finished.
    static func race<B, C>(_ fb: Kind<F, B>,
                           _ fc: Kind<F, C>) -> Kind<F, A> where A == Either<B, C> {
        F.race(fb, fc)
    }
    
    /// Runs 2 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, Z>(_ fa: Kind<F, Z>,
                            _ fb: Kind<F, B>,
                            _ f: @escaping (Z, B) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, f)
    }
    
    /// Runs 3 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, Z>(_ fa: Kind<F, Z>,
                                _ fb: Kind<F, B>,
                                _ fc: Kind<F, C>,
                                _ f: @escaping (Z, B, C) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, f)
    }
    
    /// Runs 4 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, Z>(_ fa: Kind<F, Z>,
                                   _ fb: Kind<F, B>,
                                   _ fc: Kind<F, C>,
                                   _ fd: Kind<F, D>,
                                   _ f: @escaping (Z, B, C, D) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, f)
    }
    
    /// Runs 5 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, E, Z>(_ fa: Kind<F, Z>,
                                      _ fb: Kind<F, B>,
                                      _ fc: Kind<F, C>,
                                      _ fd: Kind<F, D>,
                                      _ fe: Kind<F, E>,
                                      _ f: @escaping (Z, B, C, D, E) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, fe, f)
    }
    
    /// Runs 6 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, E, G, Z>(_ fa: Kind<F, Z>,
                                         _ fb: Kind<F, B>,
                                         _ fc: Kind<F, C>,
                                         _ fd: Kind<F, D>,
                                         _ fe: Kind<F, E>,
                                         _ fg: Kind<F, G>,
                                         _ f: @escaping (Z, B, C, D, E, G) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, fe, fg, f)
    }
    
    /// Runs 7 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, E, G, H, Z>(_ fa: Kind<F, Z>,
                                            _ fb: Kind<F, B>,
                                            _ fc: Kind<F, C>,
                                            _ fd: Kind<F, D>,
                                            _ fe: Kind<F, E>,
                                            _ fg: Kind<F, G>,
                                            _ fh: Kind<F, H>,
                                            _ f: @escaping (Z, B, C, D, E, G, H) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, fe, fg, fh, f)
    }
    
    /// Runs 8 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, E, G, H, I, Z>(_ fa: Kind<F, Z>,
                                               _ fb: Kind<F, B>,
                                               _ fc: Kind<F, C>,
                                               _ fd: Kind<F, D>,
                                               _ fe: Kind<F, E>,
                                               _ fg: Kind<F, G>,
                                               _ fh: Kind<F, H>,
                                               _ fi: Kind<F, I>,
                                               _ f: @escaping (Z, B, C, D, E, G, H, I) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, f)
    }
    
    /// Runs 9 computations in parallel and combines their results using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - fg: 6th computation.
    ///   - fh: 7th computation.
    ///   - fi: 8th computation.
    ///   - fj: 9th computation.
    ///   - f: Combination function.
    /// - Returns: A computation that describes the parallel execution.
    static func parMap<B, C, D, E, G, H, I, J, Z>(_ fa: Kind<F, Z>,
                                                  _ fb: Kind<F, B>,
                                                  _ fc: Kind<F, C>,
                                                  _ fd: Kind<F, D>,
                                                  _ fe: Kind<F, E>,
                                                  _ fg: Kind<F, G>,
                                                  _ fh: Kind<F, H>,
                                                  _ fi: Kind<F, I>,
                                                  _ fj: Kind<F, J>,
                                                  _ f: @escaping (Z, B, C, D, E, G, H, I, J) -> A) -> Kind<F, A> {
        F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, fj, f)
    }
}
