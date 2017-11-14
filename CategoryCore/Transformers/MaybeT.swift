//
//  MaybeT.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 6/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class MaybeT<F, A> : HK<F, Maybe<A>> {
    private let value : HK<F, Maybe<A>>
    
    public static func pure<Appl>(_ a : A, _ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(Maybe.pure(a)))
    }
    
    public static func none<Appl>(_ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(Maybe.none()))
    }
    
    public static func fromMaybe<Appl>(_ maybe : Maybe<A>, _ applicative : Appl) -> MaybeT<F, A> where Appl : Applicative, Appl.F == F {
        return MaybeT(applicative.pure(maybe))
    }
    
    public init(_ value : HK<F, Maybe<A>>) {
        self.value = value
    }
    
    public func fold<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> HK<F, B> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.fold(ifEmpty, f) })
    }
    
    public func cata<B, Func>(_ ifEmpty : @escaping () -> B, _ f : @escaping (A) -> B, _ functor : Func) -> HK<F, B> where Func : Functor, Func.F == F {
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
    
    public func flatMapF<B, Mon>(_ f : @escaping (A) -> HK<F, Maybe<B>>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return MaybeT<F, B>(monad.flatMap(value, { maybe in maybe.fold({ monad.pure(Maybe<B>.none()) }, f)}))
    }
    
    public func liftF<B, Func>(_ fb : HK<F, B>, _ functor : Func) -> MaybeT<F, B> where Func : Functor, Func.F == F {
        return MaybeT<F, B>(functor.map(fb, { b in Maybe<B>.some(b) }))
    }
    
    public func semiflatMap<B, Mon>(_ f : @escaping (A) -> HK<F, B>, _ monad : Mon) -> MaybeT<F, B> where Mon : Monad, Mon.F == F {
        return flatMap({ maybe in self.liftF(f(maybe), monad)}, monad)
    }
    
    public func getOrElse<Func>(_ defaultValue : A, _ functor : Func) -> HK<F, A> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.getOrElse(defaultValue) })
    }
    
    public func getOrElseF<Mon>(_ defaultValue : HK<F, A>, _ monad : Mon) -> HK<F, A> where Mon : Monad, Mon.F == F {
        return monad.flatMap(value, { maybe in maybe.fold(constF(defaultValue), monad.pure)})
    }
    
    public func filter<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> MaybeT<F, A> where Func : Functor, Func.F == F {
        return MaybeT(functor.map(value, { maybe in maybe.filter(predicate) }))
    }
    
    public func forall<Func>(_ predicate : @escaping (A) -> Bool, _ functor : Func) -> HK<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.forall(predicate) })
    }
    
    public func isDefined<Func>(_ functor : Func) -> HK<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.isDefined })
    }
    
    public func isEmpty<Func>(_ functor : Func) -> HK<F, Bool> where Func : Functor, Func.F == F {
        return functor.map(value, { maybe in maybe.isEmpty })
    }
    
    public func orElse<Mon>(_ defaultValue : MaybeT<F, A>, _ monad : Mon) -> MaybeT<F, A> where Mon : Monad, Mon.F == F {
        return MaybeT(monad.flatMap(value, { maybe in
            maybe.fold({ defaultValue  },
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



















