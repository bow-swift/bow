import Foundation

/**
 Given a 2-ary function, returns a 2-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, R>(_ f : @escaping (P1, P2) -> R) -> (P2, P1) -> R {
    return { p2, p1 in f(p1, p2) }
}

/**
 Given a 3-ary function, returns a 3-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, R>(_ f : @escaping (P1, P2, P3) -> R) -> (P3, P2, P1) -> R {
    return { p3, p2, p1 in f(p1, p2, p3) }
}

/**
 Given a 4-ary function, returns a 4-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, R>(_ f : @escaping (P1, P2, P3, P4) -> R) -> (P4, P3, P2, P1) -> R {
    return { p4, p3, p2, p1 in f(p1, p2, p3, p4) }
}

/**
 Given a 5-ary function, returns a 5-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, R>(_ f : @escaping (P1, P2, P3, P4, P5) -> R) -> (P5, P4, P3, P2, P1) -> R {
    return { p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5) }
}

/**
 Given a 6-ary function, returns a 6-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, P6, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6) -> R) -> (P6, P5, P4, P3, P2, P1) -> R {
    return { p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6) }
}

/**
 Given a 7-ary function, returns a 7-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, P6, P7, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7) -> R) -> (P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7) }
}

/**
 Given a 8-ary function, returns a 8-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8) -> R) -> (P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8) }
}

/**
 Given a 9-ary function, returns a 9-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, P9, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8, P9) -> R) -> (P9, P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p9, p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8, p9) }
}

/**
 Given a 10-ary function, returns a 10-ary function where the argument list is reversed.
 */
public func reverse<P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, R>(_ f : @escaping (P1, P2, P3, P4, P5, P6, P7, P8, P9, P10) -> R) -> (P10, P9, P8, P7, P6, P5, P4, P3, P2, P1) -> R {
    return { p10, p9, p8, p7, p6, p5, p4, p3, p2, p1 in f(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
}
