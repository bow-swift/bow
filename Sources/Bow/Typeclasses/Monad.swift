import Foundation

public protocol Monad : Applicative {
    func flatMap<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, B>
    func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> Kind<F, Either<A, B>>) -> Kind<F, B>
}

public extension Monad {
    public func ap<A, B>(_ fa: Kind<F, A>, _ ff: Kind<F, (A) -> B>) -> Kind<F, B> {
        return self.flatMap(ff, { f in self.map(fa, f) })
    }
    
    public func flatten<A>(_ ffa : Kind<F, Kind<F, A>>) -> Kind<F, A> {
        return self.flatMap(ffa, id)
    }
    
    public func followedBy<A, B>(_ fa : Kind<F, A>, _ fb : Kind<F, B>) -> Kind<F, B> {
        return self.flatMap(fa, { _ in fb })
    }
    
    public func followedByEval<A, B>(_ fa : Kind<F, A>, _ fb : Eval<Kind<F, B>>) -> Kind<F, B> {
        return self.flatMap(fa, { _ in fb.value() })
    }
    
    public func forEffect<A, B>(_ fa : Kind<F, A>, _ fb : Kind<F, B>) -> Kind<F, A> {
        return self.flatMap(fa, { a in self.map(fb, { _ in a })})
    }
    
    public func forEffectEval<A, B>(_ fa : Kind<F, A>, _ fb : Eval<Kind<F, B>>) -> Kind<F, A> {
        return self.flatMap(fa, { a in self.map(fb.value(), constant(a)) })
    }
    
    public func mproduct<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, (A, B)> {
        return self.flatMap(fa, { a in self.map(f(a), { b in (a, b) }) })
    }
    
    public func ifM<B>(_ fa : Kind<F, Bool>, _ ifTrue : @escaping () -> Kind<F, B>, _ ifFalse : @escaping () -> Kind<F, B>) -> Kind<F, B> {
        return flatMap(fa, { a in a ? ifTrue() : ifFalse() })
    }
    
    // Binding
    
    public func binding<B, C>(_ f : () -> Kind<F, B>,
                              _ fb : @escaping (B) -> Kind<F, C>) -> Kind<F, C> {
        return flatMap(f(), fb)
    }
    
    public func binding<B, C, D>(_ f : () -> Kind<F, B>,
                                 _ fb : @escaping (B) -> Kind<F, C>,
                                 _ fc : @escaping (B, C) -> Kind<F, D>) -> Kind<F, D> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                fc(b, c)
            })
        })
    }
    
    public func binding<B, C, D, E>(_ f : () -> Kind<F, B>,
                                    _ fb : @escaping (B) -> Kind<F, C>,
                                    _ fc : @escaping (B, C) -> Kind<F, D>,
                                    _ fd : @escaping (B, C, D) -> Kind<F, E>) -> Kind<F, E> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    fd(b, c, d)
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G>(_ f : () -> Kind<F, B>,
                                       _ fb : @escaping (B) -> Kind<F, C>,
                                       _ fc : @escaping (B, C) -> Kind<F, D>,
                                       _ fd : @escaping (B, C, D) -> Kind<F, E>,
                                       _ fe : @escaping (B, C, D, E) -> Kind<F, G>) -> Kind<F, G> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    self.flatMap(fd(b, c, d), { e in
                        fe(b, c, d, e)
                    })
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G, H>(_ f : () -> Kind<F, B>,
                                          _ fb : @escaping (B) -> Kind<F, C>,
                                          _ fc : @escaping (B, C) -> Kind<F, D>,
                                          _ fd : @escaping (B, C, D) -> Kind<F, E>,
                                          _ fe : @escaping (B, C, D, E) -> Kind<F, G>,
                                          _ fg : @escaping (B, C, D, E, G) -> Kind<F, H>) -> Kind<F, H> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    self.flatMap(fd(b, c, d), { e in
                        self.flatMap(fe(b, c, d, e), { g in
                            fg(b, c, d, e, g)
                        })
                    })
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G, H, I>(_ f : () -> Kind<F, B>,
                                             _ fb : @escaping (B) -> Kind<F, C>,
                                             _ fc : @escaping (B, C) -> Kind<F, D>,
                                             _ fd : @escaping (B, C, D) -> Kind<F, E>,
                                             _ fe : @escaping (B, C, D, E) -> Kind<F, G>,
                                             _ fg : @escaping (B, C, D, E, G) -> Kind<F, H>,
                                             _ fh : @escaping (B, C, D, E, G, H) -> Kind<F, I>) -> Kind<F, I> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    self.flatMap(fd(b, c, d), { e in
                        self.flatMap(fe(b, c, d, e), { g in
                            self.flatMap(fg(b, c, d, e, g), { h in
                                fh(b, c, d, e, g, h)
                            })
                        })
                    })
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G, H, I, J>(_ f : () -> Kind<F, B>,
                                                _ fb : @escaping (B) -> Kind<F, C>,
                                                _ fc : @escaping (B, C) -> Kind<F, D>,
                                                _ fd : @escaping (B, C, D) -> Kind<F, E>,
                                                _ fe : @escaping (B, C, D, E) -> Kind<F, G>,
                                                _ fg : @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                _ fh : @escaping (B, C, D, E, G, H) -> Kind<F, I>,
                                                _ fi : @escaping (B, C, D, E, G, H, I) -> Kind<F, J>) -> Kind<F, J> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    self.flatMap(fd(b, c, d), { e in
                        self.flatMap(fe(b, c, d, e), { g in
                            self.flatMap(fg(b, c, d, e, g), { h in
                                self.flatMap(fh(b, c, d, e, g, h), { i in
                                    fi(b, c, d, e, g, h, i)
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G, H, I, J, K>(_ f : () -> Kind<F, B>,
                                                   _ fb : @escaping (B) -> Kind<F, C>,
                                                   _ fc : @escaping (B, C) -> Kind<F, D>,
                                                   _ fd : @escaping (B, C, D) -> Kind<F, E>,
                                                   _ fe : @escaping (B, C, D, E) -> Kind<F, G>,
                                                   _ fg : @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                   _ fh : @escaping (B, C, D, E, G, H) -> Kind<F, I>,
                                                   _ fi : @escaping (B, C, D, E, G, H, I) -> Kind<F, J>,
                                                   _ fj : @escaping (B, C, D, E, G, H, I, J) -> Kind<F, K>) -> Kind<F, K> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    self.flatMap(fd(b, c, d), { e in
                        self.flatMap(fe(b, c, d, e), { g in
                            self.flatMap(fg(b, c, d, e, g), { h in
                                self.flatMap(fh(b, c, d, e, g, h), { i in
                                    self.flatMap(fi(b, c, d, e, g, h, i), { j in
                                        fj(b, c, d, e, g, h, i, j)
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
}

