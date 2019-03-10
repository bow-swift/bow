import Foundation

public final class ForWriterT {}
public final class WriterTPartial<F, W>: Kind2<ForWriterT, F, W> {}
public typealias WriterTOf<F, W, A> = Kind<WriterTPartial<F, W>, A>

public class WriterT<F, W, A>: WriterTOf<F, W, A> {
    fileprivate let value: Kind<F, (W, A)>

    public static func fix(_ fa : WriterTOf<F, W, A>) -> WriterT<F, W, A> {
        return fa as! WriterT<F, W, A>
    }
    
    public init(_ value : Kind<F, (W, A)>) {
        self.value = value
    }
}

public postfix func ^<F, W, A>(_ fa : WriterTOf<F, W, A>) -> WriterT<F, W, A> {
    return WriterT.fix(fa)
}

extension WriterT where F: Functor {
    public static func putT(_ fa: Kind<F, A>, _ w: W) -> WriterT<F, W, A> {
        return WriterT(fa.map { a in (w, a) })
    }

    public static func putT2(_ vf: Kind<F, A>, _ w: W) -> WriterT<F, W, A> {
        return WriterT(vf.map { v in (w, v) })
    }

    public func content() -> Kind<F, A> {
        return value.map { pair in pair.1 }
    }

    public func write() -> Kind<F, W> {
        return value.map { pair in pair.0 }
    }
}

extension WriterT where F: Functor, W: Monoid {
    public static func valueT(_ fa: Kind<F, A>) -> WriterT<F, W, A> {
        return WriterT.putT(fa, W.empty())
    }
}

extension WriterT where F: Applicative {
    public static func both(_ w: W, _ a: A) -> WriterT<F, W, A> {
        return WriterT(F.pure((w, a)))
    }

    public static func fromTuple(_ z: (W, A)) -> WriterT<F, W, A> {
        return WriterT(F.pure(z))
    }

    public static func put(_ a: A, _ w: W) -> WriterT<F, W, A> {
        return WriterT.putT(F.pure(a), w)
    }

    public static func put2(_ a: A, _ w: W) -> WriterT<F, W, A> {
        return WriterT.putT2(F.pure(a), w)
    }

    public static func tell(_ l: W) -> WriterT<F, W, Unit>  {
        return WriterT<F, W, Unit>.put(unit, l)
    }

    public func liftF<B>(_ fb: Kind<F, B>) -> WriterT<F, W, B> {
        return WriterT<F, W, B>(F.map(fb, value, { x, y in (y.0, x) }))
    }
}

extension WriterT where F: Applicative, W: Monoid {
    public static func value(_ a : A) -> WriterT<F, W, A> {
        return WriterT.put(a, W.empty())
    }
}

extension WriterT where F: Monad {
    public func transform<B, U>(_ f: @escaping ((W, A)) -> (U, B)) -> WriterT<F, U, B> {
        return WriterT<F, U, B>(value.flatMap { pair in F.pure(f(pair)) })
    }

    public func mapAcc<U>(_ f: @escaping (W) -> U) -> WriterT<F, U, A> {
        return transform({ pair in (f(pair.0), pair.1) })
    }

    public func bimap<B, U>(_ g: @escaping (W) -> U, _ f: @escaping (A) -> B) -> WriterT<F, U, B> {
        return transform({ pair in (g(pair.0), f(pair.1))})
    }

    public func subflatMap<B>(_ f: @escaping (A) -> (W, B)) -> WriterT<F, W, B> {
        return transform({ pair in f(pair.1) })
    }

    public func swap() -> WriterT<F, A, W> {
        return transform({ pair in (pair.1, pair.0) })
    }

    public func listen() -> Kind<WriterTPartial<F, W>, (W, A)> {
        return WriterT<F, W, (W, A)>(content().flatMap { a in
            self.write().map { l in
                (l, (l, a))
            }
        })
    }
}

extension WriterT where F: Monad, W: Semigroup {
    public func tell(_ w: W) -> WriterT<F, W, A> {
        return mapAcc({ inW in inW.combine(w) })
    }
}

extension WriterT where F: Monad, W: Monoid {
    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> WriterT<F, W, B> {
        return WriterT<F, W, B>.fix(flatMap({ a in self.liftF(f(a)) }))
    }

    public func reset() -> WriterT<F, W, A>  {
        return mapAcc(constant(W.empty()))
    }
}

extension WriterTPartial: EquatableK where F: EquatableK & Functor, W: Equatable {
    public static func eq<A>(_ lhs: Kind<WriterTPartial<F, W>, A>, _ rhs: Kind<WriterTPartial<F, W>, A>) -> Bool where A : Equatable {
        let wl0 = WriterT.fix(lhs).value.map { t in t.0 }
        let wl1 = WriterT.fix(lhs).value.map { t in t.1 }
        let wr0 = WriterT.fix(rhs).value.map { t in t.0 }
        let wr1 = WriterT.fix(rhs).value.map { t in t.1 }
        return wl0 == wr0 && wl1 == wr1
    }
}

extension WriterTPartial: Invariant where F: Functor {}

extension WriterTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<WriterTPartial<F, W>, A>, _ f: @escaping (A) -> B) -> Kind<WriterTPartial<F, W>, B> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.value.map { pair in (pair.0, f(pair.1)) })
    }
}

extension WriterTPartial: Applicative where F: Monad, W: Monoid {
    public static func pure<A>(_ a: A) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.pure((W.empty(), a)))
    }
}

extension WriterTPartial: Monad where F: Monad, W: Monoid {
    public static func flatMap<A, B>(_ fa: Kind<WriterTPartial<F, W>, A>, _ f: @escaping (A) -> Kind<WriterTPartial<F, W>, B>) -> Kind<WriterTPartial<F, W>, B> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.value.flatMap { pair in
            WriterT.fix(f(pair.1)).value.map { pair2 in
                (pair.0.combine(pair2.0), pair2.1)
            }
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<WriterTPartial<F, W>, Either<A, B>>) -> Kind<WriterTPartial<F, W>, B> {
        return WriterT(F.tailRecM(a, { inA in
            WriterT.fix(f(inA)).value.map { pair in
                pair.1.fold(Either.left,
                            { b in Either.right((pair.0, b)) })
            }
        }))
    }
}

extension WriterTPartial: FunctorFilter where F: MonadFilter, W: Monoid {}

extension WriterTPartial: MonadFilter where F: MonadFilter, W: Monoid {
    public static func empty<A>() -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.empty())
    }
}

extension WriterTPartial: SemigroupK where F: SemigroupK {
    public static func combineK<A>(_ x: Kind<WriterTPartial<F, W>, A>, _ y: Kind<WriterTPartial<F, W>, A>) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(WriterT.fix(x).value.combineK(WriterT.fix(y).value))
    }
}

extension WriterTPartial: MonoidK where F: MonoidK {
    public static func emptyK<A>() -> Kind<WriterTPartial<F, W>, A> {
        return WriterT(F.emptyK())
    }
}

extension WriterTPartial: MonadWriter where F: Monad, W: Monoid {
    public static func writer<A>(_ aw: (W, A)) -> Kind<WriterTPartial<F, W>, A> {
        return WriterT.put2(aw.1, aw.0)
    }

    public static func listen<A>(_ fa: Kind<WriterTPartial<F, W>, A>) -> Kind<WriterTPartial<F, W>, (W, A)> {
        return WriterT(WriterT.fix(fa).content().flatMap { a in
            WriterT.fix(fa).write().map { l in
                (l, (l, a))
            }
        })
    }

    public static func pass<A>(_ fa: Kind<WriterTPartial<F, W>, ((W) -> W, A)>) -> Kind<WriterTPartial<F, W>, A> {
        let wa = WriterT.fix(fa)
        return WriterT(wa.content().flatMap { tuple2FA in
            wa.write().map { l in
                (tuple2FA.0(l), tuple2FA.1)
            }
        })
    }
}
