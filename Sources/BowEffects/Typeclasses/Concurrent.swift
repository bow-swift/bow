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
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, fj, { a, b, c, d, e, g, h, i, j in (a, b, c, d, e, g, h, i, j) })
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
        return F.parMap(fa, fb, f)
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
        return F.parMap(fa, fb, fc, f)
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
        return F.parMap(fa, fb, fc, fd, f)
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
        return F.parMap(fa, fb, fc, fd, fe, f)
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
        return F.parMap(fa, fb, fc, fd, fe, fg, f)
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
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, f)
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
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, f)
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
        return F.parMap(fa, fb, fc, fd, fe, fg, fh, fi, fj, f)
    }
}

// MARK: Extensions for Traverse where inner effect is Concurrent

public extension Traverse {
    /// Maps each element of a structure to an effect, evaluates in parallel and collects the results.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func parTraverse<G: Concurrent, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<Self, B>> {
        let ff = f >>> ParApplicative.init
        return fa.traverse(ff)^.fa
    }
    
    /// Evaluate each effect in a structure of values in parallel and collects the results.
    ///
    /// - Parameter fga: A structure of values.
    /// - Returns: Results collected under the context of the effects.
    static func parSequence<G: Concurrent, A>(_ fa: Kind<Self, Kind<G, A>>) -> Kind<G, Kind<Self, A>> {
        parTraverse(fa, id)
    }
}

// MARK: Extensions for Traverse and Monad where inner effect is Concurrent

public extension Traverse where Self: Monad {
    /// A parallel traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    static func parFlatTraverse<G: Concurrent, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Kind<Self, B>>) -> Kind<G, Kind<Self, B>> {
        G.map(parTraverse(fa, f), Self.flatten)
    }
}

// MARK: Syntax for Kind where F is Traverse and inner effect is Concurrent

public extension Kind where F: Traverse {
    /// Maps each element of this structure to an effect, evaluates them in parallel and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func parTraverse<G: Concurrent, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<F, B>> {
        F.parTraverse(self, f)
    }
    
    /// Evaluate each effect in this structure of values in parallel and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func parSequence<G: Concurrent, AA>() -> Kind<G, Kind<F, AA>> where A == Kind<G, AA> {
        F.parSequence(self)
    }
}

// MARK: Syntax for Kind where F is Traverse and Monad and inner effect is Concurrent

public extension Kind where F: Traverse & Monad {
    /// A parallel traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func parFlatTraverse<G: Concurrent, B>(_ f: @escaping (A) -> Kind<G, Kind<F, B>>) -> Kind<G, Kind<F, B>> {
        return F.parFlatTraverse(self, f)
    }
}

fileprivate final class ForParApplicative {}
fileprivate final class ParApplicativePartial<F: Concurrent>: Kind<ForParApplicative, F> {}
fileprivate typealias ParApplicativeOf<F: Concurrent, A> = Kind<ParApplicativePartial<F>, A>

fileprivate final class ParApplicative<F: Concurrent, A>: ParApplicativeOf<F, A> {
    let fa: Kind<F, A>
    
    init(_ fa: Kind<F, A>) {
        self.fa = fa
    }
}

fileprivate postfix func ^<F, A>(_ value: ParApplicativeOf<F, A>) -> ParApplicative<F, A> {
    value as! ParApplicative<F, A>
}

extension ParApplicativePartial: Functor {
    static func map<A, B>(_ fa: Kind<ParApplicativePartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<ParApplicativePartial<F>, B> {
        ParApplicative(fa^.fa.map(f))
    }
}

extension ParApplicativePartial: Applicative {
    static func pure<A>(_ a: A) -> Kind<ParApplicativePartial<F>, A> {
        ParApplicative(F.pure(a))
    }
    
    static func ap<A, B>(_ ff: Kind<ParApplicativePartial<F>, (A) -> B>, _ fa: Kind<ParApplicativePartial<F>, A>) -> Kind<ParApplicativePartial<F>, B> {
        ParApplicative(F.parMap(ff^.fa, fa^.fa) { f, a in f(a) })
    }
}
