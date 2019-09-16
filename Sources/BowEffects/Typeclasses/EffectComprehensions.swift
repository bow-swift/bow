import Bow
import Foundation

// MARK: Utilities for Monad comprehensions and effects

/// Shiftes the execution to a given queue.
///
/// - Parameter queue: Queue where to run the effects from that point on.
/// - Returns: A binding expression to be used in a Monad comprehension.
public func continueOn<F: Async>(_ queue: DispatchQueue) -> BindingExpression<F> {
    return BoundVar<F, ()>.make() <- queue.shift()
}

/// Runs 2 computations in parallel and tuples their results.
///
/// - Parameters:
///   - fa: 1st computation.
///   - fb: 2nd computation.
/// - Returns: A computation that describes the parallel execution.
public func parallel<F: Concurrent, A, B>(_ fa: Kind<F, A>,
                                          _ fb: Kind<F, B>) -> Kind<F, (A, B)> {
    return F.parZip(fa, fb)
}

/// Runs 3 computations in parallel and tuples their results.
///
/// - Parameters:
///   - fa: 1st computation.
///   - fb: 2nd computation.
///   - fc: 3rd computation.
/// - Returns: A computation that describes the parallel execution.
public func parallel<F: Concurrent, A, B, C>(_ fa: Kind<F, A>,
                                             _ fb: Kind<F, B>,
                                             _ fc: Kind<F, C>) -> Kind<F, (A, B, C)> {
    return F.parZip(fa, fb, fc)
}

/// Runs 4 computations in parallel and tuples their results.
///
/// - Parameters:
///   - fa: 1st computation.
///   - fb: 2nd computation.
///   - fc: 3rd computation.
///   - fd: 4th computation.
/// - Returns: A computation that describes the parallel execution.
public func parallel<F: Concurrent, A, B, C, D>(_ fa: Kind<F, A>,
                                                _ fb: Kind<F, B>,
                                                _ fc: Kind<F, C>,
                                                _ fd: Kind<F, D>) -> Kind<F, (A, B, C, D)> {
    return F.parZip(fa, fb, fc, fd)
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
public func parallel<F: Concurrent, A, B, C, D, E>(_ fa: Kind<F, A>,
                                                   _ fb: Kind<F, B>,
                                                   _ fc: Kind<F, C>,
                                                   _ fd: Kind<F, D>,
                                                   _ fe: Kind<F, E>) -> Kind<F, (A, B, C, D, E)> {
    return F.parZip(fa, fb, fc, fd, fe)
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
public func parallel<F: Concurrent, A, B, C, D, E, G>(_ fa: Kind<F, A>,
                                                      _ fb: Kind<F, B>,
                                                      _ fc: Kind<F, C>,
                                                      _ fd: Kind<F, D>,
                                                      _ fe: Kind<F, E>,
                                                      _ fg: Kind<F, G>) -> Kind<F, (A, B, C, D, E, G)> {
    return F.parZip(fa, fb, fc, fd, fe, fg)
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
public func parallel<F: Concurrent, A, B, C, D, E, G, H>(_ fa: Kind<F, A>,
                                                         _ fb: Kind<F, B>,
                                                         _ fc: Kind<F, C>,
                                                         _ fd: Kind<F, D>,
                                                         _ fe: Kind<F, E>,
                                                         _ fg: Kind<F, G>,
                                                         _ fh: Kind<F, H>) -> Kind<F, (A, B, C, D, E, G, H)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh)
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
public func parallel<F: Concurrent, A, B, C, D, E, G, H, I>(_ fa: Kind<F, A>,
                                                            _ fb: Kind<F, B>,
                                                            _ fc: Kind<F, C>,
                                                            _ fd: Kind<F, D>,
                                                            _ fe: Kind<F, E>,
                                                            _ fg: Kind<F, G>,
                                                            _ fh: Kind<F, H>,
                                                            _ fi: Kind<F, I>) -> Kind<F, (A, B, C, D, E, G, H, I)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh, fi)
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
public func parallel<F: Concurrent, A, B, C, D, E, G, H, I, J>(_ fa: Kind<F, A>,
                                                               _ fb: Kind<F, B>,
                                                               _ fc: Kind<F, C>,
                                                               _ fd: Kind<F, D>,
                                                               _ fe: Kind<F, E>,
                                                               _ fg: Kind<F, G>,
                                                               _ fh: Kind<F, H>,
                                                               _ fi: Kind<F, I>,
                                                               _ fj: Kind<F, J>) -> Kind<F, (A, B, C, D, E, G, H, I, J)> {
    return F.parZip(fa, fb, fc, fd, fe, fg, fh, fi, fj)
}

