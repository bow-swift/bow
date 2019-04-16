import Foundation

/// A Monad provides functionality to sequence operations that are dependent from one another.
///
/// Instances of `Monad` must obey the following rules:
///
///     flatMap(pure(a), f) == f(a)
///     flatMap(fa, pure) == fa
///     flatMap(fa) { a in flatMap(f(a), g) } == flatMap(flatMap(fa, f), g)
///
/// Also, instances of `Monad` derive a default implementation for `Applicative.ap` as:
///
///     ap(ff, fa) == flapMap(ff, { f in map(fa, f) }
public protocol Monad: Selective {
    /// Sequentially compose two computations, passing any value produced by the first as an argument to the second.
    ///
    /// - Parameters:
    ///   - fa: First computation.
    ///   - f: A function describing the second computation, which depends on the value of the first.
    /// - Returns: Result of composing the two computations.
    static func flatMap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<Self, B>) -> Kind<Self, B>

    /// Monadic tail recursion.
    ///
    /// `tailRecM` can be used for computations that can potentially make the stack overflow.
    ///
    /// Initially introduced in [Stack Safety for Free](https://functorial.com/stack-safety-for-free/index.pdf)
    ///
    /// - Parameters:
    ///   - a: Initial value for the recursion.
    ///   - f: A function describing a recursive step.
    /// - Returns: Result of evaluating recursively the provided function with the initial value.
    static func tailRecM<A, B>(_ a: A, _ f : @escaping (A) -> Kind<Self, Either<A, B>>) -> Kind<Self, B>
}

// MARK: Related functions

public extension Monad {
    // Docs inherited from `Applicative`
    static func ap<A, B>(_ ff: Kind<Self, (A) -> B>, _ fa: Kind<Self, A>) -> Kind<Self, B> {
        return self.flatMap(ff, { f in map(fa, f) })
    }

    // Docs inherited from `Selective`
    static func select<A, B>(_ fab: Kind<Self, Either<A, B>>, _ f: Kind<Self, (A) -> B>) -> Kind<Self, B> {
        return flatMap(fab) { eab in eab.fold({ a in map(f, { ff in ff(a) }) },
                                              { b in pure(b) })}
    }

    /// Flattens a nested structure of the context implementing this instance into a single layer.
    ///
    /// - Parameter ffa: Value with a nested structure.
    /// - Returns: Value with a single context structure.
    static func flatten<A>(_ ffa: Kind<Self, Kind<Self, A>>) -> Kind<Self, A> {
        return self.flatMap(ffa, id)
    }

    /// Sequentially compose two computations, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: Result of running the second computation after the first one.
    static func followedBy<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, B> {
        return self.flatMap(fa, { _ in fb })
    }

    /// Sequentially compose a computation with a potentially lazy one, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fa: Regular computation.
    ///   - fb: Potentially lazy computation.
    /// - Returns: Result of running the second computation after the first one.
    static func followedByEval<A, B>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>) -> Kind<Self, B> {
        return self.flatMap(fa, { _ in fb.value() })
    }

    /// Sequentially compose two computations, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    /// - Returns: Result produced from the first computation after both are computed.
    static func forEffect<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>) -> Kind<Self, A> {
        return self.flatMap(fa, { a in self.map(fb, { _ in a })})
    }

    /// Sequentially compose a computation with a potentially lazy one, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fa: Regular computation.
    ///   - fb: Potentially lazy computation.
    /// - Returns: Result produced from the first computation after both are computed.
    static func forEffectEval<A, B>(_ fa: Kind<Self, A>, _ fb: Eval<Kind<Self, B>>) -> Kind<Self, A> {
        return self.flatMap(fa, { a in self.map(fb.value(), constant(a)) })
    }

    /// Pair the result of a computation with the result of applying a function to such result.
    ///
    /// - Parameters:
    ///   - fa: A computation in the context implementing this instance.
    ///   - f: A function to be applied to the result of the computation.
    /// - Returns: A tuple of the result of the computation paired with the result of the function, in the context implementing this instance.
    static func mproduct<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<Self, B>) -> Kind<Self, (A, B)> {
        return self.flatMap(fa, { a in self.map(f(a), { b in (a, b) }) })
    }

    /// Conditionally apply a closure based on the boolean result of a computation.
    ///
    /// - Parameters:
    ///   - fa: A boolean computation.
    ///   - ifTrue: Closure to be applied if the computation evaluates to `true`.
    ///   - ifFalse: Closure to be applied if the computation evaluates to `false`.
    /// - Returns: Result of applying the corresponding closure based on the result of the computation.
    static func ifM<B>(_ fa: Kind<Self, Bool>, _ ifTrue: @escaping () -> Kind<Self, B>, _ ifFalse: @escaping () -> Kind<Self, B>) -> Kind<Self, B> {
        return flatMap(fa, { a in a ? ifTrue() : ifFalse() })
    }

    // MARK: Monad comprehensions

    /// Monad comprehensions for two closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C>(_ f: () -> Kind<Self, B>,
                              _ fb: @escaping (B) -> Kind<Self, C>) -> Kind<Self, C> {
        return flatMap(f(), fb)
    }

    /// Monad comprehensions for three closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D>(_ f: () -> Kind<Self, B>,
                                 _ fb: @escaping (B) -> Kind<Self, C>,
                                 _ fc: @escaping (B, C) -> Kind<Self, D>) -> Kind<Self, D> {
        return flatMap(f(), { b in
            self.flatMap(fb(b), { c in
                fc(b, c)
            })
        })
    }

    /// Monad comprehensions for four closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E>(_ f: () -> Kind<Self, B>,
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

    /// Monad comprehensions for five closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G>(_ f: () -> Kind<Self, B>,
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

    /// Monad comprehensions for six closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H>(_ f: () -> Kind<Self, B>,
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

    /// Monad comprehensions for seven closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I>(_ f: () -> Kind<Self, B>,
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

    /// Monad comprehensions for eight closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    ///   - fi: 8th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I, J>(_ f : () -> Kind<Self, B>,
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

    /// Monad comprehensions for nine closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    ///   - fi: 8th closure providing a computation.
    ///   - fj: 9th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I, J, K>(_ f: () -> Kind<Self, B>,
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
    /// Sequentially compose this computation with another one, passing any value produced by the first as an argument to the second.
    ///
    /// This is a convenience method to call `Monad.flatMap` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: A function describing the second computation, which depends on the value of the first.
    /// - Returns: Result of composing the two computations.
    func flatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kind<F, B> {
        return F.flatMap(self, f)
    }

    /// Monadic tail recursion.
    ///
    /// This is a convenience method to call `Monad.tailRecM` as a static method of this type.
    ///
    /// - Parameters:
    ///   - a: Initial value for the recursion.
    ///   - f: A function describing a recursive step.
    /// - Returns: Result of evaluating recursively the provided function with the initial value.
    static func tailRecM<B>(_ a: A, _ f: @escaping (A) -> Kind<F, Either<A, B>>) -> Kind<F, B> {
        return F.tailRecM(a, f)
    }

    /// Flattens a nested structure of the context implementing this instance into a single layer.
    ///
    /// This is a convenience method to call `Monad.flatten` as a static method of this type.
    ///
    /// - Parameter ffa: Value with a nested structure.
    /// - Returns: Value with a single context structure.
    static func flatten(_ ffa: Kind<F, Kind<F, A>>) -> Kind<F, A> {
        return F.flatten(ffa)
    }

    /// Sequentially compose with another computation, discarding the value produced by the this one.
    ///
    /// This is a convenience method to call `Monad.followedBy` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fb: A computation.
    /// - Returns: Result of running the second computation after the first one.
    func followedBy<B>(_ fb: Kind<F, B>) -> Kind<F, B> {
        return F.followedBy(self, fb)
    }

    /// Sequentially compose this computation with a potentially lazy one, discarding the value produced by this one.
    ///
    /// This is a convenience method to call `Monad.followedByEval` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fb: Lazy computation.
    /// - Returns: Result of running the second computation after the first one.
    func followedByEval<B>(_ fb: Eval<Kind<F, B>>) -> Kind<F, B> {
        return F.followedByEval(self, fb)
    }

    /// Sequentially compose with another computation, discarding the value produced by the received one.
    ///
    /// This is a convenience method to call `Monad.forEffect` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fb: A computation.
    /// - Returns: Result produced from the first computation after both are computed.
    func forEffect<B>(_ fb: Kind<F, B>) -> Kind<F, A> {
        return F.forEffect(self, fb)
    }

    /// Sequentially compose with a potentially lazy computation, discarding the value produced by the received one.
    ///
    /// This is a convenience method to call `Monad.forEffectEval` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fb: Lazy computation.
    /// - Returns: Result produced from the first computation after both are computed.
    func forEffectEval<B>(_ fb: Eval<Kind<F, B>>) -> Kind<F, A> {
        return F.forEffectEval(self, fb)
    }

    /// Pair the result of this computation with the result of applying a function to such result.
    ///
    /// This is a convenience method to call `Monad.mproduct` as an instance method.
    ///
    /// - Parameters:
    ///   - f: A function to be applied to the result of the computation.
    /// - Returns: A tuple of the result of this computation paired with the result of the function, in the context implementing this instance.
    func mproduct<B>(_ f: @escaping (A) -> Kind<F, B>) -> Kind<F, (A, B)> {
        return F.mproduct(self, f)
    }

    // MARK: Syntax for Monad Comprehensions

    /// Monad comprehensions for two closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C>(_ f: () -> Kind<F, B>,
                              _ fb: @escaping (B) -> Kind<F, C>) -> Kind<F, C> {
        return F.binding(f, fb)
    }

    /// Monad comprehensions for three closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D>(_ f: () -> Kind<F, B>,
                                 _ fb: @escaping (B) -> Kind<F, C>,
                                 _ fc: @escaping (B, C) -> Kind<F, D>) -> Kind<F, D> {
        return F.binding(f, fb, fc)
    }

    /// Monad comprehensions for four closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E>(_ f: () -> Kind<F, B>,
                                    _ fb: @escaping (B) -> Kind<F, C>,
                                    _ fc: @escaping (B, C) -> Kind<F, D>,
                                    _ fd: @escaping (B, C, D) -> Kind<F, E>) -> Kind<F, E> {
        return F.binding(f, fb, fc, fd)
    }

    /// Monad comprehensions for five closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G>(_ f: () -> Kind<F, B>,
                                       _ fb: @escaping (B) -> Kind<F, C>,
                                       _ fc: @escaping (B, C) -> Kind<F, D>,
                                       _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                       _ fe: @escaping (B, C, D, E) -> Kind<F, G>) -> Kind<F, G> {
        return F.binding(f, fb, fc, fd, fe)
    }

    /// Monad comprehensions for six closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H>(_ f: () -> Kind<F, B>,
                                          _ fb: @escaping (B) -> Kind<F, C>,
                                          _ fc: @escaping (B, C) -> Kind<F, D>,
                                          _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                          _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                          _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>) -> Kind<F, H> {
        return F.binding(f, fb, fc, fd, fe, fg)
    }

    /// Monad comprehensions for seven closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I>(_ f: () -> Kind<F, B>,
                                             _ fb: @escaping (B) -> Kind<F, C>,
                                             _ fc: @escaping (B, C) -> Kind<F, D>,
                                             _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                             _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                             _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>,
                                             _ fh: @escaping (B, C, D, E, G, H) -> Kind<F, I>) -> Kind<F, I> {
        return F.binding(f, fb, fc, fd, fe, fg, fh)
    }

    /// Monad comprehensions for eight closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    ///   - fi: 8th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I, J>(_ f: () -> Kind<F, B>,
                                                _ fb: @escaping (B) -> Kind<F, C>,
                                                _ fc: @escaping (B, C) -> Kind<F, D>,
                                                _ fd: @escaping (B, C, D) -> Kind<F, E>,
                                                _ fe: @escaping (B, C, D, E) -> Kind<F, G>,
                                                _ fg: @escaping (B, C, D, E, G) -> Kind<F, H>,
                                                _ fh: @escaping (B, C, D, E, G, H) -> Kind<F, I>,
                                                _ fi: @escaping (B, C, D, E, G, H, I) -> Kind<F, J>) -> Kind<F, J> {
        return F.binding(f, fb, fc, fd, fe, fg, fh, fi)
    }

    /// Monad comprehensions for nine closures producing computations.
    ///
    /// Each closure is expected to provide a computation whose result may be used in subsequent computations. For this reason, the `ith` closure receives all values generated by the instructions evaluated before it.
    ///
    /// This is a convenience method to call `Monad.binding` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: 1st closure providing a computation.
    ///   - fb: 2nd closure providing a computation.
    ///   - fc: 3rd closure providing a computation.
    ///   - fd: 4th closure providing a computation.
    ///   - fe: 5th closure providing a computation.
    ///   - fg: 6th closure providing a computation.
    ///   - fh: 7th closure providing a computation.
    ///   - fi: 8th closure providing a computation.
    ///   - fj: 9th closure providing a computation.
    /// - Returns: Result of evaluating the last computation.
    static func binding<B, C, D, E, G, H, I, J, K>(_ f: () -> Kind<F, B>,
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

// MARK: Related functions

public extension Kind where F: Monad, A == Bool {
    /// Conditionally apply a closure based on the boolean result of this computation.
    ///
    /// This is a convenience method to call `Monad.ifM` as an instance method.
    ///
    /// - Parameters:
    ///   - ifTrue: Closure to be applied if the computation evaluates to `true`.
    ///   - ifFalse: Closure to be applied if the computation evaluates to `false`.
    /// - Returns: Result of applying the corresponding closure based on the result of the computation.
    func ifM<B>(_ ifTrue: @escaping () -> Kind<F, B>, _ ifFalse: @escaping () -> Kind<F, B>) -> Kind<F, B> {
        return F.ifM(self, ifTrue, ifFalse)
    }
}
