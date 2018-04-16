//
//  MaybeT.swift
//  Bow
//
//  Created by Tomás Ruiz López on 6/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ForMaybeT {}
public typealias MaybeTPartial<F> = Kind<ForMaybeT, F>

public class MaybeT<F, A> : Kind2<ForMaybeT, F, A> {
    fileprivate let value : Kind<F, Maybe<A>>
    
    public static func pure<Appl>(_ a : A, _ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(Maybe.pure(a)))
    }
    
    public static func none<Appl>(_ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(Maybe.none()))
    }
    
    public static func fromMaybe<Appl>(_ maybe : Maybe<A>, _ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(maybe))
    }
    
    public static func tailRecM<B, MonF>(_ a : A, _ f : @escaping (A) -> Kind2<ForMaybeT, F, Either<A, B>>, _ monad : MonF) -> Kind2<ForMaybeT, F, B> where MonF : Monad, MonF.F == F {
        
        return MaybeT<F, B>(monad.tailRecM(a, { aa in
            monad.map(MaybeT<F, Either<A, B>>.fix(f(aa)).value, { maybe in
                maybe.fold({ Either<A, Maybe<B>>.right(Maybe<B>.none())},
                           { either in either.map(Maybe<B>.some) })
            })
        }))
    }
    
    public static func fix(_ fa : Kind2<ForMaybeT, F, A>) -> MaybeT<F, A> {
        return fa as! MaybeT<F, A>
    }
    
    public init(_ value : Kind<F, Maybe<A>>) {
        self.value = value
    }
    
    public func fold<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> Kind<F, B> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.fold(ifEmpty, f) })
    }
    
    public func cata<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> Kind<F, B> where Func : Functor, Func.F == F {
        return fold(ifEmpty, f, functor)
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(value, { maybe in maybe.map(f) } ))
    }
    
    public func ap<B, Mon>(_ ff : MaybeT<F, (A) -> B>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return ff.flatMap({ f in self.map(f, monad) }, monad)
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> MaybeT<F, B>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return flatMapF({ a in f(a).value }, monad)
    }
    
    public func flatMapF<B, Mon>(_ f : @escaping (A) -> Kind<F, Maybe<B>>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return MaybeT<F, B>(monad.flatMap(value, { maybe in maybe.fold({ monad.pure(Maybe<B>.none()) }, f)}))
    }
    
    public func liftF<B, Func>(_ fb : Kind<F, B>, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(fb, { b in Maybe<B>.some(b) }))
    }
    
    public func semiflatMap<B, Mon>(_ f : @escaping (A) -> Kind<F, B>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return flatMap({ maybe in self.liftF(f(maybe), monad)}, monad)
    }
    
    public func getOrElse<Func>(_ defaultValue : A, _ functor : Func) -> Kind<F, A> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.getOrElse(defaultValue) })
    }
    
    public func getOrElseF<Mon>(_ defaultValue : Kind<F, A>, _ monad : Mon) -> Kind<F, A> where Mon : Monad, Mon.F == F {
        return monad.flatMap(value, { maybe in maybe.fold(constF(defaultValue), monad.pure)})
    }
    
    public func filter<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> MaybeT<F, A> where Func : Functor, Func.F == F {
        return MaybeT(functor.map(value, { maybe in maybe.filter(predicate) }))
    }
    
    public func forall<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.forall(predicate) })
    }
    
    public func isDefined<Func>(_ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.isDefined })
    }
    
    public func isEmpty<Func>(_ functor : Func) -> Kind<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.isEmpty })
    }
    
    public func orElse<Mon>(_ defaultValue : MaybeT<F, A>, _ monad : Mon) -> MaybeT<F, A> where Mon : Monad, Mon.F == F {
        return orElseF(defaultValue.value, monad)
    }
    
    public func orElseF<Mon>(_ defaultValue : Kind<F, Maybe<A>>, _ monad : Mon) -> MaybeT<F, A> where Mon : Monad, Mon.F == F {
        return MaybeT<F, A>(monad.flatMap(value, { maybe in
            maybe.fold(constF(defaultValue),
                       { _ in monad.pure(maybe) }) }))
    }
    
    public func transform<B, Func>(_ f : @escaping (Maybe<A>) -> Maybe<B>, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(value, f))
    }
    
    public func subflatMap<B, Func>(_ f : @escaping (A) -> Maybe<B>, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return transform({ maybe in maybe.flatMap(f) }, functor)
    }
    
    public func mapFilter<B, Func>(_ f : @escaping (A) -> Maybe<B>, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(value, { maybe in maybe.flatMap(f) }))
    }
}

public extension MaybeT {
    public static func functor<FuncF>(_ functor : FuncF) -> MaybeTFunctor<F, FuncF> {
        return MaybeTFunctor<F, FuncF>(functor)
    }
    
    public static func functorFilter<FuncF>(_ functor : FuncF) -> MaybeTFunctorFilter<F, FuncF> {
        return MaybeTFunctorFilter<F, FuncF>(functor)
    }
    
    public static func applicative<MonF>(_ monad : MonF) -> MaybeTApplicative<F, MonF> {
        return MaybeTApplicative<F, MonF>(monad)
    }
    
    public static func monad<MonF>(_ monad : MonF) -> MaybeTMonad<F, MonF> {
        return MaybeTMonad<F, MonF>(monad)
    }
    
    public static func semigroupK<MonF>(_ monad : MonF) -> MaybeTSemigroupK<F, MonF> {
        return MaybeTSemigroupK<F, MonF>(monad)
    }
    
    public static func monoidK<MonF>(_ monad : MonF) -> MaybeTMonoidK<F, MonF> {
        return MaybeTMonoidK<F, MonF>(monad)
    }
    
    public static func eq<EqA, Func>(_ eq : EqA, _ functor : Func) -> MaybeTEq<F, A, EqA, Func> {
        return MaybeTEq<F, A, EqA, Func>(eq, functor)
    }
}

public class MaybeTFunctor<G, FuncG> : Functor where FuncG : Functor, FuncG.F == G {
    public typealias F = MaybeTPartial<G>
    
    fileprivate let functor : FuncG
    
    public init(_ functor : FuncG) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: Kind<Kind<ForMaybeT, G>, A>, _ f: @escaping (A) -> B) -> Kind<Kind<ForMaybeT, G>, B> {
        return MaybeT.fix(fa).map(f, functor)
    }
}

public class MaybeTFunctorFilter<G, FuncG> : MaybeTFunctor<G, FuncG>, FunctorFilter where FuncG : Functor, FuncG.F == G {
    
    public func mapFilter<A, B>(_ fa: Kind<Kind<ForMaybeT, G>, A>, _ f: @escaping (A) -> Maybe<B>) -> Kind<Kind<ForMaybeT, G>, B> {
        return MaybeT.fix(fa).mapFilter(f, functor)
    }
}

public class MaybeTApplicative<G, MonG> : MaybeTFunctor<G, MonG>, Applicative where MonG : Monad, MonG.F == G {
    
    fileprivate let monad : MonG
    
    override public init(_ monad : MonG) {
        self.monad = monad
        super.init(monad)
    }
    
    public func pure<A>(_ a: A) -> Kind<Kind<ForMaybeT, G>, A> {
        return MaybeT.pure(a, monad)
    }
    
    public func ap<A, B>(_ fa: Kind<Kind<ForMaybeT, G>, A>, _ ff: Kind<Kind<ForMaybeT, G>, (A) -> B>) -> Kind<Kind<ForMaybeT, G>, B> {
        return MaybeT.fix(fa).ap(MaybeT.fix(ff), monad)
    }
}

public class MaybeTMonad<G, MonG> : MaybeTApplicative<G, MonG>, Monad where MonG : Monad, MonG.F == G {
    
    public func flatMap<A, B>(_ fa: Kind<Kind<ForMaybeT, G>, A>, _ f: @escaping (A) -> Kind<Kind<ForMaybeT, G>, B>) -> Kind<Kind<ForMaybeT, G>, B> {
        return MaybeT.fix(fa).flatMap({ a in MaybeT.fix(f(a)) }, monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<Kind<ForMaybeT, G>, Either<A, B>>) -> Kind<Kind<ForMaybeT, G>, B> {
        return MaybeT.tailRecM(a, f, monad)
    }
}

public class MaybeTSemigroupK<G, MonG> : SemigroupK where MonG : Monad, MonG.F == G {
    public typealias F = MaybeTPartial<G>
    
    fileprivate let monad : MonG
    
    public init(_ monad : MonG) {
        self.monad = monad
    }
    
    public func combineK<A>(_ x: Kind<Kind<ForMaybeT, G>, A>, _ y: Kind<Kind<ForMaybeT, G>, A>) -> Kind<Kind<ForMaybeT, G>, A> {
        return MaybeT.fix(x).orElse(MaybeT.fix(y), monad)
    }
}

public class MaybeTMonoidK<G, MonG> : MaybeTSemigroupK<G, MonG>, MonoidK where MonG : Monad, MonG.F == G {
    public func emptyK<A>() -> Kind<Kind<ForMaybeT, G>, A> {
        return MaybeT(monad.pure(Maybe.none()))
    }
}

public class MaybeTEq<F, B, EqF, Func> : Eq where EqF : Eq, EqF.A == Kind<F, MaybeOf<B>>, Func : Functor, Func.F == F {
    public typealias A = Kind2<ForMaybeT, F, B>
    
    private let eq : EqF
    private let functor : Func
    
    public init(_ eq : EqF, _ functor : Func) {
        self.eq = eq
        self.functor = functor
    }
    
    public func eqv(_ a: Kind<Kind<ForMaybeT, F>, B>, _ b: Kind<Kind<ForMaybeT, F>, B>) -> Bool {
        let a = MaybeT.fix(a)
        let b = MaybeT.fix(b)
        return eq.eqv(functor.map(a.value, { aa in aa as MaybeOf<B> }),
                      functor.map(b.value, { bb in bb as MaybeOf<B> }))
    }
}
