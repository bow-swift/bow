import Foundation

public protocol Applicative: Functor {
    static func pure<A>(_ a: A) -> Kind<Self, A>
    static func ap<A, B>(_ ff: Kind<Self, (A) -> B>, _ fa: Kind<Self, A>) -> Kind<Self, B>
}

public extension Applicative {
//    public static func map<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> Kind<Self, B>{
//        return ap(pure(f), fa)
//    }
    
    public static func product<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, (A, B)> {
        return ap(map(fa, { (a : A) in { (b : B) in (a, b) }}), fb)
    }
    
    public static func product<A, B, Z>(_ fa: Kind<Self, (A, B)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, b) })
    }
    
    public static func product<A, B, C, Z>(_ fa: Kind<Self, (A, B, C)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, b) })
    }
    
    public static func product<A, B, C, D, Z>(_ fa: Kind<Self, (A, B, C, D)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, b) })
    }
    
    public static func product<A, B, C, D, E, Z>(_ fa: Kind<Self, (A, B, C, D, E)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, b) })
    }
    
    public static func product<A, B, C, D, E, G, Z>(_ fa: Kind<Self, (A, B, C, D, E, G)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, b) })
    }
    
    public static func product<A, B, C, D, E, G, H, Z>(_ fa: Kind<Self, (A, B, C, D, E, G, H)>, _ fz: Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, H, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, b) })
    }
    
    public static func product<A, B, C, D, E, G, H, I, Z>(_ fa: Kind<Self, (A, B, C, D, E, G, H, I)>, _ fz : Kind<Self, Z>) -> Kind<Self, (A, B, C, D, E, G, H, I, Z)> {
        return map(product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, a.7, b) })
    }
    
    public static func map2Eval<A, B, Z>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>, _ f: @escaping (A, B) -> Z) -> Eval<Kind<Self, Z>> {
        return Eval.fix(fb.map{ fc in map(fa, fc, f) })
    }
    
    public static func tupled<A, B>(_ a: Kind<Self, A>,
                             _ b : Kind<Self, B>) -> Kind<Self, (A, B)> {
        return product(a, b)
    }
    
    public static func tupled<A, B, C>(_ a: Kind<Self, A>,
                                _ b: Kind<Self, B>,
                                _ c: Kind<Self, C>) -> Kind<Self, (A, B, C)> {
        return product(product(a, b), c)
    }
    
    public static func tupled<A, B, C, D>(_ a: Kind<Self, A>,
                                   _ b: Kind<Self, B>,
                                   _ c: Kind<Self, C>,
                                   _ d: Kind<Self, D>) -> Kind<Self, (A, B, C, D)> {
        return product(product(product(a, b), c), d)
    }
    
    public static func tupled<A, B, C, D, E>(_ a: Kind<Self, A>,
                                      _ b: Kind<Self, B>,
                                      _ c: Kind<Self, C>,
                                      _ d: Kind<Self, D>,
                                      _ e: Kind<Self, E>) -> Kind<Self, (A, B, C, D, E)> {
        return product(product(product(product(a, b), c), d), e)
    }
    
    public static func tupled<A, B, C, D, E, G>(_ a: Kind<Self, A>,
                                         _ b: Kind<Self, B>,
                                         _ c: Kind<Self, C>,
                                         _ d: Kind<Self, D>,
                                         _ e: Kind<Self, E>,
                                         _ g: Kind<Self, G>) -> Kind<Self, (A, B, C, D, E, G)> {
        return product(product(product(product(product(a, b), c), d), e), g)
    }
    
    public static func tupled<A, B, C, D, E, G, H>(_ a: Kind<Self, A>,
                                            _ b: Kind<Self, B>,
                                            _ c: Kind<Self, C>,
                                            _ d: Kind<Self, D>,
                                            _ e: Kind<Self, E>,
                                            _ g: Kind<Self, G>,
                                            _ h: Kind<Self, H>) -> Kind<Self, (A, B, C, D, E, G, H)> {
        return product(product(product(product(product(product(a, b), c), d), e), g), h)
    }
    
    public static func tupled<A, B, C, D, E, G, H, I>(_ a: Kind<Self, A>,
                                               _ b: Kind<Self, B>,
                                               _ c: Kind<Self, C>,
                                               _ d: Kind<Self, D>,
                                               _ e: Kind<Self, E>,
                                               _ g: Kind<Self, G>,
                                               _ h: Kind<Self, H>,
                                               _ i: Kind<Self, I>) -> Kind<Self, (A, B, C, D, E, G, H, I)> {
        return product(product(product(product(product(product(product(a, b), c), d), e), g), h), i)
    }
    
    public static func tupled<A, B, C, D, E, G, H, I, J>(_ a: Kind<Self, A>,
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
    
    public static func map<A, B, Z>(_ a: Kind<Self, A>,
                      _ b: Kind<Self, B>,
                      _ f: @escaping (A, B) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b), f)
    }
    
    public static func map<A, B, C, Z>(_ a: Kind<Self, A>,
                         _ b: Kind<Self, B>,
                         _ c: Kind<Self, C>,
                         _ f: @escaping (A, B, C) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c), f)
    }
    
    public static func map<A, B, C, D, Z>(_ a: Kind<Self, A>,
                            _ b: Kind<Self, B>,
                            _ c: Kind<Self, C>,
                            _ d: Kind<Self, D>,
                            _ f: @escaping (A, B, C, D) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d), f)
    }
    
    public static func map<A, B, C, D, E, Z>(_ a: Kind<Self, A>,
                               _ b: Kind<Self, B>,
                               _ c: Kind<Self, C>,
                               _ d: Kind<Self, D>,
                               _ e: Kind<Self, E>,
                               _ f: @escaping (A, B, C, D, E) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d, e), f)
    }
    
    public static func map<A, B, C, D, E, G, Z>(_ a: Kind<Self, A>,
                                  _ b: Kind<Self, B>,
                                  _ c: Kind<Self, C>,
                                  _ d: Kind<Self, D>,
                                  _ e: Kind<Self, E>,
                                  _ g: Kind<Self, G>,
                                  _ f: @escaping (A, B, C, D, E, G) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d, e, g), f)
    }
    
    public static func map<A, B, C, D, E, G, H, Z>(_ a: Kind<Self, A>,
                                     _ b: Kind<Self, B>,
                                     _ c: Kind<Self, C>,
                                     _ d: Kind<Self, D>,
                                     _ e: Kind<Self, E>,
                                     _ g: Kind<Self, G>,
                                     _ h: Kind<Self, H>,
                                     _ f: @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d, e, g, h), f)
    }
    
    public static func map<A, B, C, D, E, G, H, I, Z>(_ a: Kind<Self, A>,
                                        _ b: Kind<Self, B>,
                                        _ c: Kind<Self, C>,
                                        _ d: Kind<Self, D>,
                                        _ e: Kind<Self, E>,
                                        _ g: Kind<Self, G>,
                                        _ h: Kind<Self, H>,
                                        _ i: Kind<Self, I>,
                                        _ f: @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d, e, g, h, i), f)
    }
    
    public static func map<A, B, C, D, E, G, H, I, J, Z>(_ a: Kind<Self, A>,
                                           _ b: Kind<Self, B>,
                                           _ c: Kind<Self, C>,
                                           _ d: Kind<Self, D>,
                                           _ e: Kind<Self, E>,
                                           _ g: Kind<Self, G>,
                                           _ h: Kind<Self, H>,
                                           _ i: Kind<Self, I>,
                                           _ j: Kind<Self, J>,
                                           _ f: @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<Self, Z> {
        return map(tupled(a, b, c, d, e, g, h, i, j), f)
    }
}

// MARK: Syntax for Applicative
public extension Kind where F: Applicative {
    public static func pure(_ a: A) -> Kind<F, A> {
        return F.pure(a)
    }

    public func ap<AA, B>(_ fa: Kind<F, AA>) -> Kind<F, B> where A == (AA) -> B {
        return F.ap(self, fa)
    }

    public static func product<A, B>(_ fa: Kind<F, A>, _ fb: Kind<F, B>) -> Kind<F, (A, B)> {
        return F.product(fa, fb)
    }

    public static func product<A, B, Z>(_ fa: Kind<F, (A, B)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, Z>(_ fa: Kind<F, (A, B, C)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, C, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, D, Z>(_ fa: Kind<F, (A, B, C, D)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, C, D, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, D, E, Z>(_ fa: Kind<F, (A, B, C, D, E)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, C, D, E, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, D, E, G, Z>(_ fa: Kind<F, (A, B, C, D, E, G)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, D, E, G, H, Z>(_ fa: Kind<F, (A, B, C, D, E, G, H)>, _ fz: Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, H, Z)> {
        return F.product(fa, fz)
    }

    public static func product<A, B, C, D, E, G, H, I, Z>(_ fa: Kind<F, (A, B, C, D, E, G, H, I)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, H, I, Z)> {
        return F.product(fa, fz)
    }

    public static func tupled<A, B>(_ a: Kind<F, A>,
                                    _ b : Kind<F, B>) -> Kind<F, (A, B)> {
        return F.tupled(a, b)
    }

    public static func tupled<A, B, C>(_ a: Kind<F, A>,
                                       _ b: Kind<F, B>,
                                       _ c: Kind<F, C>) -> Kind<F, (A, B, C)> {
        return F.tupled(a, b, c)
    }

    public static func tupled<A, B, C, D>(_ a: Kind<F, A>,
                                          _ b: Kind<F, B>,
                                          _ c: Kind<F, C>,
                                          _ d: Kind<F, D>) -> Kind<F, (A, B, C, D)> {
        return F.tupled(a, b, c, d)
    }

    public static func tupled<A, B, C, D, E>(_ a: Kind<F, A>,
                                             _ b: Kind<F, B>,
                                             _ c: Kind<F, C>,
                                             _ d: Kind<F, D>,
                                             _ e: Kind<F, E>) -> Kind<F, (A, B, C, D, E)> {
        return F.tupled(a, b, c, d, e)
    }

    public static func tupled<A, B, C, D, E, G>(_ a: Kind<F, A>,
                                                _ b: Kind<F, B>,
                                                _ c: Kind<F, C>,
                                                _ d: Kind<F, D>,
                                                _ e: Kind<F, E>,
                                                _ g: Kind<F, G>) -> Kind<F, (A, B, C, D, E, G)> {
        return F.tupled(a, b, c, d, e, g)
    }

    public static func tupled<A, B, C, D, E, G, H>(_ a: Kind<F, A>,
                                                   _ b: Kind<F, B>,
                                                   _ c: Kind<F, C>,
                                                   _ d: Kind<F, D>,
                                                   _ e: Kind<F, E>,
                                                   _ g: Kind<F, G>,
                                                   _ h: Kind<F, H>) -> Kind<F, (A, B, C, D, E, G, H)> {
        return F.tupled(a, b, c, d, e, g, h)
    }

    public static func tupled<A, B, C, D, E, G, H, I>(_ a: Kind<F, A>,
                                                      _ b: Kind<F, B>,
                                                      _ c: Kind<F, C>,
                                                      _ d: Kind<F, D>,
                                                      _ e: Kind<F, E>,
                                                      _ g: Kind<F, G>,
                                                      _ h: Kind<F, H>,
                                                      _ i: Kind<F, I>) -> Kind<F, (A, B, C, D, E, G, H, I)> {
        return F.tupled(a, b, c, d, e, g, h, i)
    }

    public static func tupled<A, B, C, D, E, G, H, I, J>(_ a: Kind<F, A>,
                                                         _ b: Kind<F, B>,
                                                         _ c: Kind<F, C>,
                                                         _ d: Kind<F, D>,
                                                         _ e: Kind<F, E>,
                                                         _ g: Kind<F, G>,
                                                         _ h: Kind<F, H>,
                                                         _ i: Kind<F, I>,
                                                         _ j: Kind<F, J>) -> Kind<F, (A, B, C, D, E, G, H, I, J)> {
        return F.tupled(a, b, c, d, e, g, h, i, j)
    }

    public static func map<A, B, Z>(_ a: Kind<F, A>,
                                    _ b: Kind<F, B>,
                                    _ f: @escaping (A, B) -> Z) -> Kind<F, Z> {
        return F.map(a, b, f)
    }

    public static func map<A, B, C, Z>(_ a: Kind<F, A>,
                                       _ b: Kind<F, B>,
                                       _ c: Kind<F, C>,
                                       _ f: @escaping (A, B, C) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, f)
    }

    public static func map<A, B, C, D, Z>(_ a: Kind<F, A>,
                                          _ b: Kind<F, B>,
                                          _ c: Kind<F, C>,
                                          _ d: Kind<F, D>,
                                          _ f: @escaping (A, B, C, D) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, f)
    }

    public static func map<A, B, C, D, E, Z>(_ a: Kind<F, A>,
                                             _ b: Kind<F, B>,
                                             _ c: Kind<F, C>,
                                             _ d: Kind<F, D>,
                                             _ e: Kind<F, E>,
                                             _ f: @escaping (A, B, C, D, E) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, e, f)
    }

    public static func map<A, B, C, D, E, G, Z>(_ a: Kind<F, A>,
                                                _ b: Kind<F, B>,
                                                _ c: Kind<F, C>,
                                                _ d: Kind<F, D>,
                                                _ e: Kind<F, E>,
                                                _ g: Kind<F, G>,
                                                _ f: @escaping (A, B, C, D, E, G) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, e, g, f)
    }

    public static func map<A, B, C, D, E, G, H, Z>(_ a: Kind<F, A>,
                                                   _ b: Kind<F, B>,
                                                   _ c: Kind<F, C>,
                                                   _ d: Kind<F, D>,
                                                   _ e: Kind<F, E>,
                                                   _ g: Kind<F, G>,
                                                   _ h: Kind<F, H>,
                                                   _ f: @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, e, g, h, f)
    }

    public static func map<A, B, C, D, E, G, H, I, Z>(_ a: Kind<F, A>,
                                                      _ b: Kind<F, B>,
                                                      _ c: Kind<F, C>,
                                                      _ d: Kind<F, D>,
                                                      _ e: Kind<F, E>,
                                                      _ g: Kind<F, G>,
                                                      _ h: Kind<F, H>,
                                                      _ i: Kind<F, I>,
                                                      _ f: @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, e, g, h, i, f)
    }

    public static func map<A, B, C, D, E, G, H, I, J, Z>(_ a: Kind<F, A>,
                                                         _ b: Kind<F, B>,
                                                         _ c: Kind<F, C>,
                                                         _ d: Kind<F, D>,
                                                         _ e: Kind<F, E>,
                                                         _ g: Kind<F, G>,
                                                         _ h: Kind<F, H>,
                                                         _ i: Kind<F, I>,
                                                         _ j: Kind<F, J>,
                                                         _ f: @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<F, Z> {
        return F.map(a, b, c, d, e, g, h, i, j, f)
    }
}
