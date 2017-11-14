//
//  EitherT.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 6/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class EitherTF {}

public class EitherT<F, A, B> : HK3<EitherTF, F, A, B> {
    private let value : HK<F, Either<A, B>>
    
    public static func left<Appl>(_ a : A, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(Either<A, B>.left(a)))
    }
    
    public static func right<Appl>(_ b : B, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(Either<A, B>.right(b)))
    }
    
    public static func pure<Appl>(_ b : B, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return right(b, applicative)
    }
    
    public static func fromEither<Appl>(_ either : Either<A, B>, _ applicative : Appl) -> EitherT<F, A, B> where Appl : Applicative, Appl.F == F {
        return EitherT(applicative.pure(either))
    }
    
    public init(_ value : HK<F, Either<A, B>>) {
        self.value = value
    }
    
    public func fold<C, Func>(_ fa : @escaping (A) -> C, _ fb : @escaping (B) -> C, _ functor : Func) -> HK<F, C> where Func : Functor, Func.F == F {
        return functor.map(value) { either in either.fold(fa, fb) }
    }
    
    public func map<C, Func>(_ f : @escaping (B) -> C, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return EitherT<F, A, C>(functor.map(value, { either in either.map(f) }))
    }
    
    public func liftF<C, Func>(_ fc : HK<F, C>, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return EitherT<F, A, C>(functor.map(fc, Either<A, C>.right))
    }
    
    public func ap<C, Mon>(_ ff : EitherT<F, A, (B) -> C>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return ff.flatMap({ f in self.map(f, monad) }, monad)
    }
    
    public func flatMap<C, Mon>(_ f : @escaping (B) -> EitherT<F, A, C>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return flatMapF({ b in f(b).value }, monad)
    }
    
    public func flatMapF<C, Mon>(_ f : @escaping (B) -> HK<F, Either<A, C>>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return EitherT<F, A, C>(monad.flatMap(value, { either in
            either.fold({ a in monad.pure(Either<A, C>.left(a)) },
                        { b in f(b) })
        }))
    }
    
    public func cata<C, Func>(_ l : @escaping (A) -> C, _ r : @escaping (B) -> C, _ functor : Func) -> HK<F, C> where Func : Functor, Func.F == F {
        return fold(l, r, functor)
    }
    
    public func semiflatMap<C, Mon>(_ f : @escaping (B) -> HK<F, C>, _ monad : Mon) -> EitherT<F, A, C> where Mon : Monad, Mon.F == F {
        return flatMap({ b in self.liftF(f(b), monad) }, monad)
    }
    
    public func exists<Func>(_ predicate : @escaping (B) -> Bool, _ functor : Func) -> HK<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { either in either.exists(predicate) })
    }
    
    public func transform<C, D, Func>(_ f : @escaping (Either<A, B>) -> Either<C, D>, _ functor : Func) -> EitherT<F, C, D> where Func : Functor, Func.F == F {
        return EitherT<F, C, D>(functor.map(value, f))
    }
    
    public func subflatpMap<C, Func>(_ f : @escaping (B) -> Either<A, C>, _ functor : Func) -> EitherT<F, A, C> where Func : Functor, Func.F == F {
        return transform({ either in either.flatMap(f) }, functor)
    }
    
    public func toMaybeT<Func>(_ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(value, { either in either.toMaybe() } ))
    }
    
    public func combineK<Mon>(_ y : EitherT<F, A, B>, _ monad : Mon) -> EitherT<F, A, B> where Mon : Monad, Mon.F == F {
        return EitherT<F, A, B>(monad.flatMap(value, { either in
            either.fold(constF(y.value), { b in monad.pure(Either<A, B>.right(b)) })
        }))
    }
}































