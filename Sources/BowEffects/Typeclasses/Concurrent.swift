import Foundation
import Bow

public protocol Concurrent: Async {
    static func parMap<A, B, Z>(_ fa: Kind<Self, A>,
                                _ fb: Kind<Self, B>,
                                _ f: @escaping (A, B) -> Z) -> Kind<Self, Z>
    static func parMap<A, B, C, Z>(_ fa: Kind<Self, A>,
                                   _ fb: Kind<Self, B>,
                                   _ fc: Kind<Self, C>,
                                   _ f: @escaping (A, B, C) -> Z) -> Kind<Self, Z>
}

// MARK: Related functions

public extension Concurrent {
    static func parMap<A, B, C, D, Z>(_ fa: Kind<Self, A>,
                                      _ fb: Kind<Self, B>,
                                      _ fc: Kind<Self, C>,
                                      _ fd: Kind<Self, D>,
                                      _ f: @escaping (A, B, C, D) -> Z) -> Kind<Self, Z> {
        return Self.parMap(Self.parMap(fa, fb, { a, b in (a, b) }),
                           Self.parMap(fc, fd, { c, d in (c, d) }),
                           { x, y in f(x.0, x.1, y.0, y.1) })
    }
    
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
    static func parMap<B, Z>(_ fa: Kind<F, Z>,
                            _ fb: Kind<F, B>,
                            _ f: @escaping (Z, B) -> A) -> Kind<F, A> {
        return F.parMap(fa, fb, f)
    }
    
    static func parMap<B, C, Z>(_ fa: Kind<F, Z>,
                                _ fb: Kind<F, B>,
                                _ fc: Kind<F, C>,
                                _ f: @escaping (Z, B, C) -> A) -> Kind<F, A> {
        return F.parMap(fa, fb, fc, f)
    }
    
    static func parMap<B, C, D, Z>(_ fa: Kind<F, Z>,
                                   _ fb: Kind<F, B>,
                                   _ fc: Kind<F, C>,
                                   _ fd: Kind<F, D>,
                                   _ f: @escaping (Z, B, C, D) -> A) -> Kind<F, A> {
        return F.parMap(fa, fb, fc, fd, f)
    }
    
    static func parMap<B, C, D, E, Z>(_ fa: Kind<F, Z>,
                                      _ fb: Kind<F, B>,
                                      _ fc: Kind<F, C>,
                                      _ fd: Kind<F, D>,
                                      _ fe: Kind<F, E>,
                                      _ f: @escaping (Z, B, C, D, E) -> A) -> Kind<F, A> {
        return F.parMap(fa, fb, fc, fd, fe, f)
    }
    
    static func parMap<B, C, D, E, G, Z>(_ fa: Kind<F, Z>,
                                         _ fb: Kind<F, B>,
                                         _ fc: Kind<F, C>,
                                         _ fd: Kind<F, D>,
                                         _ fe: Kind<F, E>,
                                         _ fg: Kind<F, G>,
                                         _ f: @escaping (Z, B, C, D, E, G) -> A) -> Kind<F, A> {
        return F.parMap(fa, fb, fc, fd, fe, fg, f)
    }
    
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
