import Foundation

/// Reverses the inputs of a 2-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, R>(_ f : @escaping (P1, P2) -> R) -> (P2, P1) -> R {
    return { p2, p1 in f(p1, p2) }
}

/// Reverses the inputs of a 3-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, R>(_ f : @escaping (P1, P2, P3) -> R) -> (P3, P2, P1) -> R {
    return { p3, p2, p1 in f(p1, p2, p3) }
}

/// Reverses the inputs of a 4-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, R>(_ f : @escaping (P1, P2, P3, P4) -> R) -> (P4, P3, P2, P1) -> R {
    return { p4, p3, p2, p1 in f(p1, p2, p3, p4) }
}

/// Reverses the inputs of a 5-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, R>(_ f : @escaping (P1, P2, P3, P4, P5) -> R) -> (P5, P4, P3, P2, P1) -> R {
    return { p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5) }
}

/// Reverses the inputs of a 6-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, P6, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6) -> R) -> (P6, P5, P4, P3, P2, P1) -> R {
    return { p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6) }
}

/// Reverses the inputs of a 7-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, P6, P7, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7) -> R) -> (P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7) }
}

/// Reverses the inputs of a 8-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8) -> R) -> (P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8) }
}

/// Reverses the inputs of a 9-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, P9, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8, P9) -> R) -> (P9, P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p9, p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8, p9) }
}

/// Reverses the inputs of a 10-ary function.
///
/// - Parameter f: Function whose inputs should be reversed.
/// - Returns: A function with the same behaviour as `f` but with reversed input parameters.
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8, P9, P10) -> R) -> (P10, P9, P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p10, p9, p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
}
