import Foundation

public final class ForOptionT {}
public final class OptionTPartial<F>: Kind<ForOptionT, F> {}
public typealias OptionTOf<F, A> = Kind<OptionTPartial<F>, A>

public class OptionT<F, A> : OptionTOf<F, A> {
    fileprivate let value : Kind<F, Option<A>>

    public static func fix(_ fa : OptionTOf<F, A>) -> OptionT<F, A> {
        return fa as! OptionT<F, A>
    }
    
    public init(_ value : Kind<F, Option<A>>) {
        self.value = value
    }
}

extension OptionT where F: Functor {
    public func fold<B>(_ ifEmpty: @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return value.map { option in option.fold(ifEmpty, f) }
    }

    public func cata<B>(_ ifEmpty: @escaping () -> B, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return fold(ifEmpty, f)
    }

    public func liftF<B>(_ fb: Kind<F, B>) -> OptionT<F, B> {
        return OptionT<F, B>(fb.map(Option<B>.some))
    }

    public func getOrElse(_ defaultValue: A) -> Kind<F, A> {
        return value.map { option in option.getOrElse(defaultValue) }
    }

    public var isDefined: Kind<F, Bool> {
        return value.map { option in option.isDefined }
    }

    public func transform<B>(_ f: @escaping (Option<A>) -> Option<B>) -> OptionT<F, B> {
        return OptionT<F, B>(value.map(f))
    }

    public func subflatMap<B>(_ f: @escaping (A) -> Option<B>) -> OptionT<F, B> {
        return transform { option in Option.fix(option.flatMap(f)) }
    }
}

extension OptionT where F: Applicative {
    public static func none() -> OptionT<F, A> {
        return OptionT(F.pure(.none()))
    }

    public static func some(_ a: A) -> OptionT<F, A> {
        return OptionT(F.pure(.some(a)))
    }

    public static func fromOption(_ option: Option<A>) -> OptionT<F, A> {
        return OptionT(F.pure(option))
    }
}

extension OptionT where F: Monad {
    public func orElse(_ defaultValue: OptionT<F, A>) -> OptionT<F, A> {
        return orElseF(defaultValue.value)
    }

    public func orElseF(_ defaultValue: Kind<F, Option<A>>) -> OptionT<F, A> {
        return OptionT<F, A>(value.flatMap { option in
            option.fold(constant(defaultValue),
                        constant(F.pure(option))) })
    }

    public func semiflatMap<B>(_ f: @escaping (A) -> Kind<F, B>) -> OptionT<F, B> {
        return OptionT<F, B>.fix(self.flatMap({ option in self.liftF(f(option)) }))
    }

    public func getOrElseF(_ defaultValue: Kind<F, A>) -> Kind<F, A> {
        return value.flatMap { option in option.fold(constant(defaultValue), F.pure) }
    }
}

extension OptionTPartial: EquatableK where F: EquatableK {
    public static func eq<A>(_ lhs: Kind<OptionTPartial<F>, A>, _ rhs: Kind<OptionTPartial<F>, A>) -> Bool where A : Equatable {
        return OptionT.fix(lhs).value == OptionT.fix(rhs).value
    }
}

extension OptionTPartial: Invariant where F: Functor {}

extension OptionTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> B) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.map { a in Option.fix(a.map(f)) })
    }
}

extension OptionTPartial: FunctorFilter where F: Functor {
    public static func mapFilter<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.map { option in Option.fix(option.flatMap(f)) })
    }
}

extension OptionTPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.pure(.some(a)))
    }

    public static func ap<A, B>(_ ff: Kind<OptionTPartial<F>, (A) -> B>, _ fa: Kind<OptionTPartial<F>, A>) -> Kind<OptionTPartial<F>, B> {
        let otf = OptionT.fix(ff)
        let ota = OptionT.fix(fa)
        return OptionT(F.map(otf.value, ota.value) { of, oa in Option.fix(of.ap(oa)) })
    }
}

// MARK: Instance of `Selective` for `OptionT`
extension OptionTPartial: Selective where F: Monad {}

extension OptionTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<OptionTPartial<F>, A>, _ f: @escaping (A) -> Kind<OptionTPartial<F>, B>) -> Kind<OptionTPartial<F>, B> {
        let ota = OptionT.fix(fa)
        return OptionT(ota.value.flatMap { option in
            option.fold({ F.pure(Option<B>.none()) },
                        { a in OptionT.fix(f(a)).value })
        })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<OptionTPartial<F>, Either<A, B>>) -> Kind<OptionTPartial<F>, B> {
        return OptionT(F.tailRecM(a, { aa in
            OptionT.fix(f(aa)).value.map { option in
                option.fold({ Either.right(Option.none())},
                            { either in Either.fix(either.map(Option.some)) })
            }
        }))
    }
}

extension OptionTPartial: SemigroupK where F: Monad {
    public static func combineK<A>(_ x: Kind<OptionTPartial<F>, A>, _ y: Kind<OptionTPartial<F>, A>) -> Kind<OptionTPartial<F>, A> {
        return OptionT.fix(x).orElse(OptionT.fix(y))
    }
}

extension OptionTPartial: MonoidK where F: Monad {
    public static func emptyK<A>() -> Kind<OptionTPartial<F>, A> {
        return OptionT(F.pure(.none()))
    }
}
