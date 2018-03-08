//
//  Monad.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Monad : Applicative {
    func flatMap<A, B>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<F, B>) -> HK<F, B>
    func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> HK<F, Either<A, B>>) -> HK<F, B>
}

public extension Monad {
    public func ap<A, B>(_ fa: HK<F, A>, _ ff: HK<F, (A) -> B>) -> HK<F, B> {
        return self.flatMap(ff, { f in self.map(fa, f) })
    }
    
    public func flatten<A>(_ ffa : HK<F, HK<F, A>>) -> HK<F, A> {
        return self.flatMap(ffa, id)
    }
    
    public func followedBy<A, B>(_ fa : HK<F, A>, _ fb : HK<F, B>) -> HK<F, B> {
        return self.flatMap(fa, { _ in fb })
    }
    
    public func followedByEval<A, B>(_ fa : HK<F, A>, _ fb : Eval<HK<F, B>>) -> HK<F, B> {
        return self.flatMap(fa, { _ in fb.value() })
    }
    
    public func forEffect<A, B>(_ fa : HK<F, A>, _ fb : HK<F, B>) -> HK<F, A> {
        return self.flatMap(fa, { a in self.map(fb, { _ in a })})
    }
    
    public func forEffectEval<A, B>(_ fa : HK<F, A>, _ fb : Eval<HK<F, B>>) -> HK<F, A> {
        return self.flatMap(fa, { a in self.map(fb.value(), constF(a)) })
    }
    
    public func mproduct<A, B>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<F, B>) -> HK<F, (A, B)> {
        return self.flatMap(fa, { a in self.map(f(a), { b in (a, b) }) })
    }
    
    public func ifM<B>(_ fa : HK<F, Bool>, _ ifTrue : @escaping () -> HK<F, B>, _ ifFalse : @escaping () -> HK<F, B>) -> HK<F, B> {
        return flatMap(fa, { a in a ? ifTrue() : ifFalse() })
    }
    
    // Binding
    
    public func binding<B, C>(_ f : () -> HK<F, B>,
                              _ fb : @escaping (B) -> HK<F, C>) -> HK<F, C> {
        return flatMap(f(), fb)
    }
    
    public func binding<B, C, D>(_ f : () -> HK<F, B>,
                                 _ fb : @escaping (B) -> HK<F, C>,
                                 _ fc : @escaping (B, C) -> HK<F, D>) -> HK<F, D> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                fc(b, c)
            })
        })
    }
    
    public func binding<B, C, D, E>(_ f : () -> HK<F, B>,
                                    _ fb : @escaping (B) -> HK<F, C>,
                                    _ fc : @escaping (B, C) -> HK<F, D>,
                                    _ fd : @escaping (B, C, D) -> HK<F, E>) -> HK<F, E> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                self.flatMap(fc(b, c), { d in
                    fd(b, c, d)
                })
            })
        })
    }
    
    public func binding<B, C, D, E, G>(_ f : () -> HK<F, B>,
                                       _ fb : @escaping (B) -> HK<F, C>,
                                       _ fc : @escaping (B, C) -> HK<F, D>,
                                       _ fd : @escaping (B, C, D) -> HK<F, E>,
                                       _ fe : @escaping (B, C, D, E) -> HK<F, G>) -> HK<F, G> {
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
    
    public func binding<B, C, D, E, G, H>(_ f : () -> HK<F, B>,
                                          _ fb : @escaping (B) -> HK<F, C>,
                                          _ fc : @escaping (B, C) -> HK<F, D>,
                                          _ fd : @escaping (B, C, D) -> HK<F, E>,
                                          _ fe : @escaping (B, C, D, E) -> HK<F, G>,
                                          _ fg : @escaping (B, C, D, E, G) -> HK<F, H>) -> HK<F, H> {
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
    
    public func binding<B, C, D, E, G, H, I>(_ f : () -> HK<F, B>,
                                             _ fb : @escaping (B) -> HK<F, C>,
                                             _ fc : @escaping (B, C) -> HK<F, D>,
                                             _ fd : @escaping (B, C, D) -> HK<F, E>,
                                             _ fe : @escaping (B, C, D, E) -> HK<F, G>,
                                             _ fg : @escaping (B, C, D, E, G) -> HK<F, H>,
                                             _ fh : @escaping (B, C, D, E, G, H) -> HK<F, I>) -> HK<F, I> {
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
    
    public func binding<B, C, D, E, G, H, I, J>(_ f : () -> HK<F, B>,
                                                _ fb : @escaping (B) -> HK<F, C>,
                                                _ fc : @escaping (B, C) -> HK<F, D>,
                                                _ fd : @escaping (B, C, D) -> HK<F, E>,
                                                _ fe : @escaping (B, C, D, E) -> HK<F, G>,
                                                _ fg : @escaping (B, C, D, E, G) -> HK<F, H>,
                                                _ fh : @escaping (B, C, D, E, G, H) -> HK<F, I>,
                                                _ fi : @escaping (B, C, D, E, G, H, I) -> HK<F, J>) -> HK<F, J> {
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
    
    public func binding<B, C, D, E, G, H, I, J, K>(_ f : () -> HK<F, B>,
                                                   _ fb : @escaping (B) -> HK<F, C>,
                                                   _ fc : @escaping (B, C) -> HK<F, D>,
                                                   _ fd : @escaping (B, C, D) -> HK<F, E>,
                                                   _ fe : @escaping (B, C, D, E) -> HK<F, G>,
                                                   _ fg : @escaping (B, C, D, E, G) -> HK<F, H>,
                                                   _ fh : @escaping (B, C, D, E, G, H) -> HK<F, I>,
                                                   _ fi : @escaping (B, C, D, E, G, H, I) -> HK<F, J>,
                                                   _ fj : @escaping (B, C, D, E, G, H, I, J) -> HK<F, K>) -> HK<F, K> {
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

