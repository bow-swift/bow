import Foundation

public protocol Applicative : Functor {
    func pure<A>(_ a : A) -> Kind<F, A>
    func ap<A, B>(_ ff : Kind<F, (A) -> B>, _ fa : Kind<F, A>) -> Kind<F, B>
}

public extension Applicative {
    public func map<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return ap(pure(f), fa)
    }
    
    public func product<A, B>(_ fa : Kind<F, A>, _ fb : Kind<F, B>) -> Kind<F, (A, B)> {
        return ap(self.map(fa, { (a : A) in { (b : B) in (a, b) }}), fb)
    }
    
    public func product<A, B, Z>(_ fa : Kind<F, (A, B)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, b) })
    }
    
    public func product<A, B, C, Z>(_ fa : Kind<F, (A, B, C)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, b) })
    }
    
    public func product<A, B, C, D, Z>(_ fa : Kind<F, (A, B, C, D)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, b) })
    }
    
    public func product<A, B, C, D, E, Z>(_ fa : Kind<F, (A, B, C, D, E)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, E, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, b) })
    }
    
    public func product<A, B, C, D, E, G, Z>(_ fa : Kind<F, (A, B, C, D, E, G)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, b) })
    }
    
    public func product<A, B, C, D, E, G, H, Z>(_ fa : Kind<F, (A, B, C, D, E, G, H)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, H, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, b) })
    }
    
    public func product<A, B, C, D, E, G, H, I, Z>(_ fa : Kind<F, (A, B, C, D, E, G, H, I)>, _ fz : Kind<F, Z>) -> Kind<F, (A, B, C, D, E, G, H, I, Z)> {
        return self.map(self.product(fa, fz), { a, b in (a.0, a.1, a.2, a.3, a.4, a.5, a.6, a.7, b) })
    }
    
    public func map2<A, B, Z>(_ fa : Kind<F, A>, _ fb : Kind<F, B>, _ f : @escaping (A, B) -> Z) -> Kind<F, Z> {
        return map(product(fa, fb), f)
    }
    
    public func map2Eval<A, B, Z>(_ fa : Kind<F, A>, _ fb : Eval<Kind<F, B>>, _ f : @escaping (A, B) -> Z) -> Eval<Kind<F, Z>> {
        return fb.map{ fc in self.map2(fa, fc, f) }
    }
    
    public func tupled<A, B>(_ a : Kind<F, A>,
                             _ b : Kind<F, B>) -> Kind<F, (A, B)> {
        return product(a, b)
    }
    
    public func tupled<A, B, C>(_ a : Kind<F, A>,
                                _ b : Kind<F, B>,
                                _ c : Kind<F, C>) -> Kind<F, (A, B, C)> {
        return product(product(a, b), c)
    }
    
    public func tupled<A, B, C, D>(_ a : Kind<F, A>,
                                   _ b : Kind<F, B>,
                                   _ c : Kind<F, C>,
                                   _ d : Kind<F, D>) -> Kind<F, (A, B, C, D)> {
        return product(product(product(a, b), c), d)
    }
    
    public func tupled<A, B, C, D, E>(_ a : Kind<F, A>,
                                      _ b : Kind<F, B>,
                                      _ c : Kind<F, C>,
                                      _ d : Kind<F, D>,
                                      _ e : Kind<F, E>) -> Kind<F, (A, B, C, D, E)> {
        return product(product(product(product(a, b), c), d), e)
    }
    
    public func tupled<A, B, C, D, E, G>(_ a : Kind<F, A>,
                                         _ b : Kind<F, B>,
                                         _ c : Kind<F, C>,
                                         _ d : Kind<F, D>,
                                         _ e : Kind<F, E>,
                                         _ g : Kind<F, G>) -> Kind<F, (A, B, C, D, E, G)> {
        return product(product(product(product(product(a, b), c), d), e), g)
    }
    
    public func tupled<A, B, C, D, E, G, H>(_ a : Kind<F, A>,
                                            _ b : Kind<F, B>,
                                            _ c : Kind<F, C>,
                                            _ d : Kind<F, D>,
                                            _ e : Kind<F, E>,
                                            _ g : Kind<F, G>,
                                            _ h : Kind<F, H>) -> Kind<F, (A, B, C, D, E, G, H)> {
        return product(product(product(product(product(product(a, b), c), d), e), g), h)
    }
    
    public func tupled<A, B, C, D, E, G, H, I>(_ a : Kind<F, A>,
                                               _ b : Kind<F, B>,
                                               _ c : Kind<F, C>,
                                               _ d : Kind<F, D>,
                                               _ e : Kind<F, E>,
                                               _ g : Kind<F, G>,
                                               _ h : Kind<F, H>,
                                               _ i : Kind<F, I>) -> Kind<F, (A, B, C, D, E, G, H, I)> {
        return product(product(product(product(product(product(product(a, b), c), d), e), g), h), i)
    }
    
    public func tupled<A, B, C, D, E, G, H, I, J>(_ a : Kind<F, A>,
                                                  _ b : Kind<F, B>,
                                                  _ c : Kind<F, C>,
                                                  _ d : Kind<F, D>,
                                                  _ e : Kind<F, E>,
                                                  _ g : Kind<F, G>,
                                                  _ h : Kind<F, H>,
                                                  _ i : Kind<F, I>,
                                                  _ j : Kind<F, J>) -> Kind<F, (A, B, C, D, E, G, H, I, J)> {
        return product(product(product(product(product(product(product(product(a, b), c), d), e), g), h), i), j)
    }
    
    func map<A, B, Z>(_ a : Kind<F, A>,
                      _ b : Kind<F, B>,
                      _ f : @escaping (A, B) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b), f)
    }
    
    func map<A, B, C, Z>(_ a : Kind<F, A>,
                         _ b : Kind<F, B>,
                         _ c : Kind<F, C>,
                         _ f : @escaping (A, B, C) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c), f)
    }
    
    func map<A, B, C, D, Z>(_ a : Kind<F, A>,
                            _ b : Kind<F, B>,
                            _ c : Kind<F, C>,
                            _ d : Kind<F, D>,
                            _ f : @escaping (A, B, C, D) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d), f)
    }
    
    func map<A, B, C, D, E, Z>(_ a : Kind<F, A>,
                               _ b : Kind<F, B>,
                               _ c : Kind<F, C>,
                               _ d : Kind<F, D>,
                               _ e : Kind<F, E>,
                               _ f : @escaping (A, B, C, D, E) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d, e), f)
    }
    
    func map<A, B, C, D, E, G, Z>(_ a : Kind<F, A>,
                                  _ b : Kind<F, B>,
                                  _ c : Kind<F, C>,
                                  _ d : Kind<F, D>,
                                  _ e : Kind<F, E>,
                                  _ g : Kind<F, G>,
                                  _ f : @escaping (A, B, C, D, E, G) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d, e, g), f)
    }
    
    func map<A, B, C, D, E, G, H, Z>(_ a : Kind<F, A>,
                                     _ b : Kind<F, B>,
                                     _ c : Kind<F, C>,
                                     _ d : Kind<F, D>,
                                     _ e : Kind<F, E>,
                                     _ g : Kind<F, G>,
                                     _ h : Kind<F, H>,
                                     _ f : @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d, e, g, h), f)
    }
    
    func map<A, B, C, D, E, G, H, I, Z>(_ a : Kind<F, A>,
                                        _ b : Kind<F, B>,
                                        _ c : Kind<F, C>,
                                        _ d : Kind<F, D>,
                                        _ e : Kind<F, E>,
                                        _ g : Kind<F, G>,
                                        _ h : Kind<F, H>,
                                        _ i : Kind<F, I>,
                                        _ f : @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d, e, g, h, i), f)
    }
    
    func map<A, B, C, D, E, G, H, I, J, Z>(_ a : Kind<F, A>,
                                           _ b : Kind<F, B>,
                                           _ c : Kind<F, C>,
                                           _ d : Kind<F, D>,
                                           _ e : Kind<F, E>,
                                           _ g : Kind<F, G>,
                                           _ h : Kind<F, H>,
                                           _ i : Kind<F, I>,
                                           _ j : Kind<F, J>,
                                           _ f : @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<F, Z> {
        return map(tupled(a, b, c, d, e, g, h, i, j), f)
    }
}

