import Foundation

public protocol Monad: Applicative {
    static func flatMap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<Self, B>) -> Kind<Self, B>
    static func tailRecM<A, B>(_ a: A, _ f : @escaping (A) -> Kind<Self, Either<A, B>>) -> Kind<Self, B>
}

public extension Monad {
    public static func ap<A, B>(_ ff: Kind<Self, (A) -> B>, _ fa: Kind<Self, A>) -> Kind<Self, B> {
        return self.flatMap(ff, { f in map(fa, f) })
    }
    
    public static func flatten<A>(_ ffa: Kind<Self, Kind<Self, A>>) -> Kind<Self, A> {
        return self.flatMap(ffa, id)
    }
    
    public static func followedBy<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, B> {
        return self.flatMap(fa, { _ in fb })
    }
    
    public static func followedByEval<A, B>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>) -> Kind<Self, B> {
        return self.flatMap(fa, { _ in fb.value() })
    }
    
    public static func forEffect<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, A> {
        return self.flatMap(fa, { a in self.map(fb, { _ in a })})
    }
    
    public static func forEffectEval<A, B>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>) -> Kind<Self, A> {
        return self.flatMap(fa, { a in self.map(fb.value(), constant(a)) })
    }
    
    public static func mproduct<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<Self, B>) -> Kind<Self, (A, B)> {
        return self.flatMap(fa, { a in self.map(f(a), { b in (a, b) }) })
    }
    
    public static func ifM<B>(_ fa: Kind<Self, Bool>, _ ifTrue: @escaping () -> Kind<Self, B>, _ ifFalse: @escaping () -> Kind<Self, B>) -> Kind<Self, B> {
        return flatMap(fa, { a in a ? ifTrue() : ifFalse() })
    }
    
    // Binding
    
    public static func binding<B, C>(_ f: () -> Kind<Self, B>,
                              _ fb: @escaping (B) -> Kind<Self, C>) -> Kind<Self, C> {
        return flatMap(f(), fb)
    }
    
    public static func binding<B, C, D>(_ f: () -> Kind<Self, B>,
                                 _ fb: @escaping (B) -> Kind<Self, C>,
                                 _ fc: @escaping (B, C) -> Kind<Self, D>) -> Kind<Self, D> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                fc(b, c)
            })
        })
    }
    
    public static func binding<B, C, D, E>(_ f: () -> Kind<Self, B>,
                                    _ fb: @escaping (B) -> Kind<Self, C>,
                                    _ fc: @escaping (B, C) -> Kind<Self, D>,
                                    _ fd: @escaping (B, C, D) -> Kind<Self, E>) -> Kind<Self, E> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    fd(b, c, d)
                })
            })
        })
    }
    
    public static func binding<B, C, D, E, G>(_ f: () -> Kind<Self, B>,
                                       _ fb: @escaping (B) -> Kind<Self, C>,
                                       _ fc: @escaping (B, C) -> Kind<Self, D>,
                                       _ fd: @escaping (B, C, D) -> Kind<Self, E>,
                                       _ fe: @escaping (B, C, D, E) -> Kind<Self, G>) -> Kind<Self, G> {
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
    
    public static func binding<B, C, D, E, G, H>(_ f: () -> Kind<Self, B>,
                                          _ fb: @escaping (B) -> Kind<Self, C>,
                                          _ fc: @escaping (B, C) -> Kind<Self, D>,
                                          _ fd: @escaping (B, C, D) -> Kind<Self, E>,
                                          _ fe: @escaping (B, C, D, E) -> Kind<Self, G>,
                                          _ fg: @escaping (B, C, D, E, G) -> Kind<Self, H>) -> Kind<Self, H> {
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
    
    public static func binding<B, C, D, E, G, H, I>(_ f: () -> Kind<Self, B>,
                                             _ fb: @escaping (B) -> Kind<Self, C>,
                                             _ fc: @escaping (B, C) -> Kind<Self, D>,
                                             _ fd: @escaping (B, C, D) -> Kind<Self, E>,
                                             _ fe: @escaping (B, C, D, E) -> Kind<Self, G>,
                                             _ fg: @escaping (B, C, D, E, G) -> Kind<Self, H>,
                                             _ fh: @escaping (B, C, D, E, G, H) -> Kind<Self, I>) -> Kind<Self, I> {
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
    
    public static func binding<B, C, D, E, G, H, I, J>(_ f : () -> Kind<Self, B>,
                                                _ fb: @escaping (B) -> Kind<Self, C>,
                                                _ fc: @escaping (B, C) -> Kind<Self, D>,
                                                _ fd: @escaping (B, C, D) -> Kind<Self, E>,
                                                _ fe: @escaping (B, C, D, E) -> Kind<Self, G>,
                                                _ fg: @escaping (B, C, D, E, G) -> Kind<Self, H>,
                                                _ fh: @escaping (B, C, D, E, G, H) -> Kind<Self, I>,
                                                _ fi: @escaping (B, C, D, E, G, H, I) -> Kind<Self, J>) -> Kind<Self, J> {
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
    
    public static func binding<B, C, D, E, G, H, I, J, K>(_ f: () -> Kind<Self, B>,
                                                   _ fb: @escaping (B) -> Kind<Self, C>,
                                                   _ fc: @escaping (B, C) -> Kind<Self, D>,
                                                   _ fd: @escaping (B, C, D) -> Kind<Self, E>,
                                                   _ fe: @escaping (B, C, D, E) -> Kind<Self, G>,
                                                   _ fg: @escaping (B, C, D, E, G) -> Kind<Self, H>,
                                                   _ fh: @escaping (B, C, D, E, G, H) -> Kind<Self, I>,
                                                   _ fi: @escaping (B, C, D, E, G, H, I) -> Kind<Self, J>,
                                                   _ fj: @escaping (B, C, D, E, G, H, I, J) -> Kind<Self, K>) -> Kind<Self, K> {
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

// MARK: Syntax for Monad

public extension Kind where F: Monad {
    public func flatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kind<F, B> {
        return F.flatMap(self, f)
    }

    public static func tailRecM<B>(_ a: A, _ f: @escaping (A) -> Kind<F, Either<A, B>>) -> Kind<F, B> {
        return F.tailRecM(a, f)
    }

    public static func flatten(_ ffa: Kind<F, Kind<F, A>>) -> Kind<F, A> {
        return F.flatten(ffa)
    }

    public func followedBy<B>(_ fb: Kind<F, B>) -> Kind<F, B> {
        return F.followedBy(self, fb)
    }

    public func followedByEval<B>(_ fb: Eval<Kind<F, B>>) -> Kind<F, B> {
        return F.followedByEval(self, fb)
    }

    public func forEffect<B>(_ fb: Kind<F, B>) -> Kind<F, A> {
        return F.forEffect(self, fb)
    }

    public func forEffectEval<B>(_ fb: Eval<Kind<F, B>>) -> Kind<F, A> {
        return F.forEffectEval(self, fb)
    }

    public func mproduct<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kind<F, (A, B)> {
        return F.mproduct(self, f)
    }

    public static func binding<B, C>(_ f: () -> Kind<F, B>,
                                     _ fb: @escaping (B) -> Kind<F, C>) -> Kind<F, C> {
        return F.binding(f, fb)
    }

    public static func binding<B, C, D>(_ f: () -> Kind<F, B>,
                                        _ fb: @escaping (B) -> Kind<F, C>,
                                        _ fc: @escaping (B, C) -> Kind<F, D>) -> Kind<F, D> {
        return F.binding(f, fb, fc)
    }

    public static func binding<B, C, D, E>(_ f: () -> Kind<F, B>,
                                           _ fb: @escaping (B) -> Kind<F, C>,
                                           _ fc: @escaping (B, C) -> Kind<F, D>,
                                           _ fd: @escaping (B, C, D) -> Kind<F, E>) -> Kind<F, E> {
        return F.binding(f, fb, fc, fd)
    }

    public static func binding<B, C, D, E, G>(_ f: () -> Kind<F, B>,
                                              _ fb: @escaping (B) -> Kind<F, C>,
                                              _ fc: @escaping (B, C) -> Kind<F, D>,
                                              _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                              _ fe: @escaping (B, C, D, E) -> Kind<F, G>) -> Kind<F, G> {
        return F.binding(f, fb, fc, fd, fe)
    }

    public static func binding<B, C, D, E, G, H>(_ f: () -> Kind<F, B>,
                                                 _ fb: @escaping (B) -> Kind<F, C>,
                                                 _ fc: @escaping (B, C) -> Kind<F, D>,
                                                 _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                                 _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                                 _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>) -> Kind<F, H> {
        return F.binding(f, fb, fc, fd, fe, fg)
    }

    public static func binding<B, C, D, E, G, H, I>(_ f: () -> Kind<F, B>,
                                                    _ fb: @escaping (B) -> Kind<F, C>,
                                                    _ fc: @escaping (B, C) -> Kind<F, D>,
                                                    _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                                    _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                                    _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                    _ fh: @escaping (B, C, D, E, G, H) -> Kind<F, I>) -> Kind<F, I> {
        return F.binding(f, fb, fc, fd, fe, fg, fh)
    }

    public static func binding<B, C, D, E, G, H, I, J>(_ f: () -> Kind<F, B>,
                                                       _ fb: @escaping (B) -> Kind<F, C>,
                                                       _ fc: @escaping (B, C) -> Kind<F, D>,
                                                       _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                                       _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                                       _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                       _ fh: @escaping (B, C, D, E, G, H) -> Kind<F, I>,
                                                       _ fi: @escaping (B, C, D, E, G, H, I) -> Kind<F, J>) -> Kind<F, J> {
        return F.binding(f, fb, fc, fd, fe, fg, fh, fi)
    }

    public static func binding<B, C, D, E, G, H, I, J, K>(_ f: () -> Kind<F, B>,
                                                          _ fb: @escaping (B) -> Kind<F, C>,
                                                          _ fc: @escaping (B, C) -> Kind<F, D>,
                                                          _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                                          _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                                          _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                          _ fh: @escaping (B, C, D, E, G, H) -> Kind<F, I>,
                                                          _ fi: @escaping (B, C, D, E, G, H, I) -> Kind<F, J>,
                                                          _ fj: @escaping (B, C, D, E, G, H, I, J) -> Kind<F, K>) -> Kind<F, K> {
        return F.binding(f, fb, fc, fd, fe, fg, fh, fi, fj)
    }

}

public extension Kind where F: Monad, A == Bool {
    public func ifM<B>(_ ifTrue: @escaping () -> Kind<F, B>, _ ifFalse: @escaping () -> Kind<F, B>) -> Kind<F, B> {
        return F.ifM(self, ifTrue, ifFalse)
    }
}
