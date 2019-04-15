import Foundation
import Bow

public typealias ConnectedProcF<F, E, A> = (KindConnection<F>, @escaping Callback<E, A>) -> Kind<F, ()>
public typealias ConnectedProc<F, E, A> = (KindConnection<F>, @escaping Callback<E, A>) -> ()

public typealias RacePair<F, A, B> = Either<(A, Fiber<F, B>), (Fiber<F, A>, B)>
public typealias RaceTriple<F, A, B, C> = Either<(A, Fiber<F, B>, Fiber<F, C>), Either<(Fiber<F, A>, B, Fiber<F, C>), (Fiber<F, A>, Fiber<F, B>, C)>>

public typealias Race2<A, B> = Either<A, B>
public typealias Race3<A, B, C> = Either<Either<A, B>, C>
public typealias Race4<A, B, C, D> = Either<Either<A, B>, Either<C, D>>
public typealias Race5<A, B, C, D, E> = Either<Race3<A, B, C>, Race2<D, E>>
public typealias Race6<A, B, C, D, E, G> = Either<Race3<A, B, C>, Race3<D, E, G>>
public typealias Race7<A, B, C, D, E, G, H> = Race3<Race3<A, B, C>, Race2<D, E>, Race2<G, H>>
public typealias Race8<A, B, C, D, E, G, H, I> = Race4<Race2<A, B>, Race2<C, D>, Race2<E, G>, Race2<H, I>>
public typealias Race9<A, B, C, D, E, G, H, I, J> = Race4<Race3<A, B, C>, Race2<D, E>, Race2<G, H>, Race2<I, J>>

public protocol Concurrent: Async {
    static func asyncF<A>(_ fa: @escaping ConnectedProcF<Self, E, A>) -> Kind<Self, A>
    static func startFiber<A>(_ fa: Kind<Self, A>, _ queue: DispatchQueue) -> Kind<Self, Fiber<Self, A>>
    static func racePair<A, B>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ queue: DispatchQueue) -> Kind<Self, RacePair<Self, A, B>>
    static func raceTriple<A, B, C>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ fc: Kind<Self, C>, _ queue: DispatchQueue) -> Kind<Self, RaceTriple<Self, A, B, C>>
}

// MARK: Related functions

public extension Concurrent {
    public static func async<A>(_ fa: @escaping ConnectedProc<Self, E, A>) -> Kind<Self, A> {
        return asyncF { conn, cb in delay { fa(conn, cb) } }
    }

    public static func cancelableF<A>(_ k: @escaping (@escaping Callback<E, A>) -> Kind<Self, CancelToken<Self>>) -> Kind<Self, A> {
        return asyncF { cb in
            let state = Atomic<Callback<E, ()>?>(nil)
            let cb1 = { (r: Either<E, A>) -> () in
                cb(r)
                if !state.setIfNil({ _ in () }) {
                    if let cb2 = state.value {
                        state.setNil()
                        cb2(Either<E, ()>.right(()))
                    }
                }
            }

            return k(cb1).bracketCase({ token, exitCase in
                switch(exitCase) {
                case .canceled: return token
                default: return pure(())
                }
            }, { _ in Kind<Self, ()>.async { cb in
                    if !state.setIfNil(cb) {
                        cb(Either<E, ()>.right(()))
                    }
                }
            })
        }
    }

    public static func cancelable<A>(_ k: @escaping (@escaping Callback<E, A>) -> CancelToken<Self>) -> Kind<Self, A> {
        return cancelableF { cb in delay { k(cb) } }
    }

    public static func asyncF<A>(_ procf: @escaping ProcF<Self, E, A>) -> Kind<Self, A> {
        return asyncF { _, cb in procf(cb) }
    }
}

// MARK: Syntax for Concurrent on DispatchQueue

public extension DispatchQueue {
    public func startFiber<F: Concurrent, A>(_ fa: Kind<F, A>) -> Kind<F, Fiber<F, A>> {
        return F.startFiber(fa, self)
    }

    public func parMap<F: Concurrent, A, B, Z>(_ fa: Kind<F, A>,
                                               _ fb: Kind<F, B>,
                                               _ f: @escaping (A, B) -> Z) -> Kind<F, Z> {
        return F.racePair(fa, fb, self).flatMap { either in
            either.fold(
                { (a, fiberB) in fiberB.join().map { b in f(a, b) } },
                { (fiberA, b) in fiberA.join().map { a in f(a, b) } })
            }
    }

    public func parMap<F: Concurrent, A, B, C, Z>(_ fa: Kind<F, A>,
                                                  _ fb: Kind<F, B>,
                                                  _ fc: Kind<F, C>,
                                                  _ f: @escaping (A, B, C) -> Z) -> Kind<F, Z> {
        return F.raceTriple(fa, fb, fc, self).flatMap { race in
            fold(race,
                 { a, fiberB, fiberC in fiberB.join().flatMap { b in fiberC.join().map { c in f(a, b, c) } } },
                 { fiberA, b, fiberC in fiberA.join().flatMap { a in fiberC.join().map { c in f(a, b, c) } } },
                 { fiberA, fiberB, c in fiberA.join().flatMap { a in fiberB.join().map { b in f(a, b, c) } } })
        }
    }

    public func parMap<F: Concurrent, A, B, C, D, Z>(_ fa: Kind<F, A>,
                                                     _ fb: Kind<F, B>,
                                                     _ fc: Kind<F, C>,
                                                     _ fd: Kind<F, D>,
                                                     _ f: @escaping (A, B, C, D) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, { a, b in (a, b) }),
                      parMap(fc, fd, { c, d in (c, d) }),
                      { x, y in f(x.0, x.1, y.0, y.1) })
    }

    public func parMap<F: Concurrent, A, B, C, D, E, Z>(_ fa: Kind<F, A>,
                                                        _ fb: Kind<F, B>,
                                                        _ fc: Kind<F, C>,
                                                        _ fd: Kind<F, D>,
                                                        _ fe: Kind<F, E>,
                                                        _ f: @escaping (A, B, C, D, E) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                      parMap(fd, fe, { d, e in (d, e) }),
                      { x, y in f(x.0, x.1, x.2, y.0, y.1) })
    }

    public func parMap<F: Concurrent, A, B, C, D, E, G, Z>(_ fa: Kind<F, A>,
                                                           _ fb: Kind<F, B>,
                                                           _ fc: Kind<F, C>,
                                                           _ fd: Kind<F, D>,
                                                           _ fe: Kind<F, E>,
                                                           _ fg: Kind<F, G>,
                                                           _ f: @escaping (A, B, C, D, E, G) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                      parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                      { x, y in f(x.0, x.1, x.2, y.0, y.1, y.2) })
    }

    public func parMap<F: Concurrent, A, B, C, D, E, G, H, Z>(_ fa: Kind<F, A>,
                                                              _ fb: Kind<F, B>,
                                                              _ fc: Kind<F, C>,
                                                              _ fd: Kind<F, D>,
                                                              _ fe: Kind<F, E>,
                                                              _ fg: Kind<F, G>,
                                                              _ fh: Kind<F, H>,
                                                              _ f: @escaping (A, B, C, D, E, G, H) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                      parMap(fd, fe, { d, e in (d, e) }),
                      parMap(fg, fh, { g, h in (g, h) }),
                      { x, y, z in f(x.0, x.1, x.2, y.0, y.1, z.0, z.1) }
        )
    }

    public func parMap<F: Concurrent, A, B, C, D, E, G, H, I, Z>(_ fa: Kind<F, A>,
                                                                 _ fb: Kind<F, B>,
                                                                 _ fc: Kind<F, C>,
                                                                 _ fd: Kind<F, D>,
                                                                 _ fe: Kind<F, E>,
                                                                 _ fg: Kind<F, G>,
                                                                 _ fh: Kind<F, H>,
                                                                 _ fi: Kind<F, I>,
                                                                 _ f: @escaping (A, B, C, D, E, G, H, I) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                      parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                      parMap(fh, fi, { h, i in (h, i) }),
                      { x, y, z in f(x.0, x.1, x.2, y.0, y.1, y.2, z.0, z.1) })
    }

    public func parMap<F: Concurrent, A, B, C, D, E, G, H, I, J, Z>(_ fa: Kind<F, A>,
                                                                    _ fb: Kind<F, B>,
                                                                    _ fc: Kind<F, C>,
                                                                    _ fd: Kind<F, D>,
                                                                    _ fe: Kind<F, E>,
                                                                    _ fg: Kind<F, G>,
                                                                    _ fh: Kind<F, H>,
                                                                    _ fi: Kind<F, I>,
                                                                    _ fj: Kind<F, J>,
                                                                    _ f: @escaping (A, B, C, D, E, G, H, I, J) -> Z) -> Kind<F, Z> {
        return parMap(parMap(fa, fb, fc, { a, b, c in (a, b, c) }),
                      parMap(fd, fe, fg, { d, e, g in (d, e, g) }),
                      parMap(fh, fi, fj, { h, i, j in (h, i, j) }),
                      { x, y, z in f(x.0, x.1, x.2, y.0, y.1, y.2, z.0, z.1, z.2) })
    }

    public func race<F: Concurrent, A, B>(_ fa: Kind<F, A>, _ fb: Kind<F, B>) -> Kind<F, Race2<A, B>> {
        return F.racePair(fa, fb, self).flatMap { either in
            either.fold({ x in
                let (a, fiberB) = x
                return fiberB.cancel().map { .left(a) }
            },
                        { y in
                let (fiberA, b) = y
                return fiberA.cancel().map { .right(b) }
            })
        }
    }

    public func race<F: Concurrent, A, B, C>(_ fa: Kind<F, A>, _ fb: Kind<F, B>, _ fc: Kind<F, C>) -> Kind<F, Race3<A, B, C>> {
        return F.raceTriple(fa, fb, fc, self).flatMap { raceTriple in
            fold(raceTriple,
                 { (a, fiberB, fiberC) in fiberB.cancel().flatMap { _ in fiberC.cancel().map { _ in .left(.left(a)) } } },
                 { (fiberA, b, fiberC) in fiberA.cancel().flatMap { _ in fiberC.cancel().map { _ in .left(.right(b)) } } },
                 { (fiberA, fiberB, c) in fiberA.cancel().flatMap { _ in fiberB.cancel().map { _ in .right(c) } } })
        }
    }

    public func race<F: Concurrent, A, B, C, D>(_ fa: Kind<F, A>,
                                                _ fb: Kind<F, B>,
                                                _ fc: Kind<F, C>,
                                                _ fd: Kind<F, D>) -> Kind<F, Race4<A, B, C, D>> {
        return race(race(fa, fb),
                    race(fc, fd))
    }

    public func race<F: Concurrent, A, B, C, D, E>(_ fa: Kind<F, A>,
                                                   _ fb: Kind<F, B>,
                                                   _ fc: Kind<F, C>,
                                                   _ fd: Kind<F, D>,
                                                   _ fe: Kind<F, E>) -> Kind<F, Race5<A, B, C, D, E>> {
        return race(race(fa, fb, fc),
                    race(fd, fe))
    }

    public func race<F: Concurrent, A, B, C, D, E, G>(_ fa: Kind<F, A>,
                                                      _ fb: Kind<F, B>,
                                                      _ fc: Kind<F, C>,
                                                      _ fd: Kind<F, D>,
                                                      _ fe: Kind<F, E>,
                                                      _ fg: Kind<F, G>) -> Kind<F, Race6<A, B, C, D, E, G>> {
        return race(race(fa, fb, fc),
                    race(fd, fe, fg))
    }

    public func race<F: Concurrent, A, B, C, D, E, G, H>(_ fa: Kind<F, A>,
                                                         _ fb: Kind<F, B>,
                                                         _ fc: Kind<F, C>,
                                                         _ fd: Kind<F, D>,
                                                         _ fe: Kind<F, E>,
                                                         _ fg: Kind<F, G>,
                                                         _ fh: Kind<F, H>) -> Kind<F, Race7<A, B, C, D, E, G, H>> {
        return race(race(fa, fb, fc),
                    race(fd, fe),
                    race(fg, fh))
    }

    public func race<F: Concurrent, A, B, C, D, E, G, H, I>(_ fa: Kind<F, A>,
                                                            _ fb: Kind<F, B>,
                                                            _ fc: Kind<F, C>,
                                                            _ fd: Kind<F, D>,
                                                            _ fe: Kind<F, E>,
                                                            _ fg: Kind<F, G>,
                                                            _ fh: Kind<F, H>,
                                                            _ fi: Kind<F, I>) -> Kind<F, Race8<A, B, C, D, E, G, H, I>> {
        return race(race(fa, fb),
                    race(fc, fd),
                    race(fe, fg),
                    race(fh, fi))
    }

    public func race<F: Concurrent, A, B, C, D, E, G, H, I, J>(_ fa: Kind<F, A>,
                                                               _ fb: Kind<F, B>,
                                                               _ fc: Kind<F, C>,
                                                               _ fd: Kind<F, D>,
                                                               _ fe: Kind<F, E>,
                                                               _ fg: Kind<F, G>,
                                                               _ fh: Kind<F, H>,
                                                               _ fi: Kind<F, I>,
                                                               _ fj: Kind<F, J>) -> Kind<F, Race9<A, B, C, D, E, G, H, I, J>> {
        return race(race(fa, fb, fc),
                    race(fd, fe),
                    race(fg, fh),
                    race(fi, fj))
    }
}

// MARK: Utilities for folding RaceN

private func fold<F, A, B, C, Z>(_ x: RaceTriple<F, A, B, C>,
                                 _ fa: @escaping (A, Fiber<F, B>, Fiber<F, C>) -> Z,
                                 _ fb: @escaping (Fiber<F, A>, B, Fiber<F, C>) -> Z,
                                 _ fc: @escaping (Fiber<F, A>, Fiber<F, B>, C) -> Z) -> Z {
    return x.fold(fa, { y in y.fold(fb, fc) })
}

public func fold<A, B, C, Z>(_ race: Race3<A, B, C>,
                              _ ifA: @escaping (A) -> Z,
                              _ ifB: @escaping (B) -> Z,
                              _ ifC: @escaping (C) -> Z) -> Z {
    return race.fold({ x in x.fold(ifA, ifB)}, ifC)
}

public func fold<A, B, C, D, Z>(_ race: Race4<A, B, C, D>,
                                _ ifA: @escaping (A) -> Z,
                                _ ifB: @escaping (B) -> Z,
                                _ ifC: @escaping (C) -> Z,
                                _ ifD: @escaping (D) -> Z) -> Z {
    return race.fold({ x in x.fold(ifA, ifB)}, { y in y.fold(ifC, ifD) })
}

public func fold<A, B, C, D, E, Z>(_ race: Race5<A, B, C, D, E>,
                                   _ ifA: @escaping (A) -> Z,
                                   _ ifB: @escaping (B) -> Z,
                                   _ ifC: @escaping (C) -> Z,
                                   _ ifD: @escaping (D) -> Z,
                                   _ ifE: @escaping (E) -> Z) -> Z {
    return race.fold({ x in fold(x, ifA, ifB, ifC) }, { y in y.fold(ifD, ifE) })
}

public func fold<A, B, C, D, E, G, Z>(_ race: Race6<A, B, C, D, E, G>,
                                      _ ifA: @escaping (A) -> Z,
                                      _ ifB: @escaping (B) -> Z,
                                      _ ifC: @escaping (C) -> Z,
                                      _ ifD: @escaping (D) -> Z,
                                      _ ifE: @escaping (E) -> Z,
                                      _ ifG: @escaping (G) -> Z) -> Z {
    return race.fold({ x in fold(x, ifA, ifB, ifC) }, { y in fold(y, ifD, ifE, ifG) })
}

public func fold<A, B, C, D, E, G, H, Z>(_ race: Race7<A, B, C, D, E, G, H>,
                                         _ ifA: @escaping (A) -> Z,
                                         _ ifB: @escaping (B) -> Z,
                                         _ ifC: @escaping (C) -> Z,
                                         _ ifD: @escaping (D) -> Z,
                                         _ ifE: @escaping (E) -> Z,
                                         _ ifG: @escaping (G) -> Z,
                                         _ ifH: @escaping (H) -> Z) -> Z {
    return race.fold({ x in fold(x, ifA, ifB, ifC, ifD, ifE) }, { y in y.fold(ifG, ifH) })
}

public func fold<A, B, C, D, E, G, H, I, Z>(_ race: Race8<A, B, C, D, E, G, H, I>,
                                            _ ifA: @escaping (A) -> Z,
                                            _ ifB: @escaping (B) -> Z,
                                            _ ifC: @escaping (C) -> Z,
                                            _ ifD: @escaping (D) -> Z,
                                            _ ifE: @escaping (E) -> Z,
                                            _ ifG: @escaping (G) -> Z,
                                            _ ifH: @escaping (H) -> Z,
                                            _ ifI: @escaping (I) -> Z) -> Z {
    return race.fold({ x in fold(x, ifA, ifB, ifC, ifD) }, { y in fold(y, ifE, ifG, ifH, ifI) })
}

public func fold<A, B, C, D, E, G, H, I, J, Z>(_ race: Race9<A, B, C, D, E, G, H, I, J>,
                                               _ ifA: @escaping (A) -> Z,
                                               _ ifB: @escaping (B) -> Z,
                                               _ ifC: @escaping (C) -> Z,
                                               _ ifD: @escaping (D) -> Z,
                                               _ ifE: @escaping (E) -> Z,
                                               _ ifG: @escaping (G) -> Z,
                                               _ ifH: @escaping (H) -> Z,
                                               _ ifI: @escaping (I) -> Z,
                                               _ ifJ: @escaping (J) -> Z) -> Z {
    return race.fold({ x in fold(x, ifA, ifB, ifC, ifD, ifE) }, { y in fold(y, ifG, ifH, ifI, ifJ) })
}

// MARK: Syntax for Concurrent

public extension Kind where F: Concurrent {
    public static func asyncF(_ fa: @escaping ConnectedProcF<F, F.E, A>) -> Kind<F, A> {
        return F.asyncF(fa)
    }

    public static func startFiber(_ fa: Kind<F, A>, _ queue: DispatchQueue) -> Kind<F, Fiber<F, A>> {
        return F.startFiber(fa, queue)
    }

    public static func racePair<B>(_ fa: Kind<F, A>, _ fb: Kind<F, B>, _ queue: DispatchQueue) -> Kind<F, RacePair<F, A, B>> {
        return F.racePair(fa, fb, queue)
    }

    public static func raceTriple<B, C>(_ fa: Kind<F, A>, _ fb: Kind<F, B>, _ fc: Kind<F, C>, _ queue: DispatchQueue) -> Kind<F, RaceTriple<F, A, B, C>> {
        return F.raceTriple(fa, fb, fc, queue)
    }

    public static func async(_ fa: @escaping ConnectedProc<F, F.E, A>) -> Kind<F, A> {
        return F.async(fa)
    }

    public static func cancelableF(_ k: @escaping (@escaping Callback<F.E, A>) -> Kind<F, CancelToken<F>>) -> Kind<F, A> {
        return F.cancelableF(k)
    }

    public static func cancelable(_ k: @escaping (@escaping Callback<F.E, A>) -> CancelToken<F>) -> Kind<F, A> {
        return F.cancelable(k)
    }

    public static func asyncF(_ procf: @escaping ProcF<F, F.E, A>) -> Kind<F, A> {
        return F.asyncF(procf)
    }
}
