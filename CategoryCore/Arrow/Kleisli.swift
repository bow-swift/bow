//
//  Kleisli.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public typealias ReaderT<F, D, A> = Kleisli<F, D, A>

public class Kleisli<F, D, A> : HK2<F, D, A> {
    private let run : (D) -> HK<F, A>
    
    public init(_ run : @escaping (D) -> HK<F, A>) {
        self.run = run
    }
    
    public func ap<B, Appl>(_ ff : Kleisli<F, D, (A) -> B>, _ applicative : Appl) -> Kleisli<F, D, B> where Appl : Applicative, Appl.F == F {
        return Kleisli<F, D, B>({ d in applicative.ap(self.run(d), ff.run(d)) })
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> Kleisli<F, D, B> where Func : Functor, Func.F == F {
        return Kleisli<F, D, B>({ d in functor.map(self.run(d), f) })
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> Kleisli<F, D, B>, _ monad : Mon)  -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return Kleisli<F, D, B>({ d in monad.flatMap(self.run(d), { a in f(a).run(d) }) })
    }
    
    public func zip<B, Mon>(_ o : Kleisli<F, D, B>, _ monad : Mon) -> Kleisli<F, D, (A, B)> where Mon : Monad, Mon.F == F {
        return self.flatMap({ a in
            o.map({ b in (a, b) }, monad)
        }, monad)
    }
    
    public func local<DD>(_ f : @escaping (DD) -> D) -> Kleisli<F, DD, A> {
        return Kleisli<F, DD, A>({ dd in self.run(f(dd)) })
    }
    
    public func andThen<C, Mon>(_ f : Kleisli<F, A, C>, _ monad : Mon) -> Kleisli<F, D, C> where Mon : Monad, Mon.F == F {
        return andThen(f.run, monad)
    }
    
    public func andThen<B, Mon>(_ f : @escaping (A) -> HK<F, B>, _ monad : Mon) -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return Kleisli<F, D, B>({ d in monad.flatMap(self.run(d), f) })
    }
    
    public func andThen<B, Mon>(_ a : HK<F, B>, _ monad : Mon) -> Kleisli<F, D, B> where Mon : Monad, Mon.F == F {
        return andThen({ _ in a }, monad)
    }
    
    public func handleErrorWith<E, MonErr>(_ f : @escaping (E) -> Kleisli<F, D, A>, _ monadError : MonErr) -> Kleisli<F, D, A> where MonErr : MonadError, MonErr.F == F, MonErr.E == E {
        return Kleisli<F, D, A>({ d in monadError.handleErrorWith(self.run(d), { e in f(e).run(d) }) })
    }
    
    public static func pure<Appl>(_ a : A, _ applicative : Appl) -> Kleisli<F, D, A> where Appl : Applicative, Appl.F == F {
        return Kleisli<F, D, A>({ _ in applicative.pure(a) })
    }
    
    public static func ask<Appl>(_ applicative : Appl) -> Kleisli<F, D, D> where Appl : Applicative, Appl.F == F {
        return Kleisli<F, D, D>({ d in applicative.pure(d) })
    }
    
    public static func raiseError<E, MonErr>(_ e : E, _ monadError : MonErr) -> Kleisli<F, D, A> where MonErr : MonadError, MonErr.F == F, MonErr.E == E {
        return Kleisli<F, D, A>({ _ in monadError.raiseError(e) })
    }
}

