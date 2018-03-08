//
//  FlatmapOperator.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 17/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

infix operator >>= : AdditionPrecedence

public func >>=<A, B>(_ fa : Function0<A>, _ f : @escaping (A) -> Function0<B>) -> Function0<B> {
    return fa.flatMap(f)
}

public func >>=<A, B, C>(_ fa : Function1<A, B>, _ f : @escaping (B) -> Function1<A, C>) -> Function1<A, C> {
    return fa.flatMap(f)
}

public func >>=<A, B, C>(_ fa : Either<A, B>, _ f : @escaping (B) -> Either<A, C>) -> Either<A, C> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : Eval<A>, _ f : @escaping (A) -> Eval<B>) -> Eval<B> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : Id<A>, _ f : @escaping (A) -> Id<B>) -> Id<B> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : ListKW<A>, _ f : @escaping (A) -> ListKW<B>) -> ListKW<B> {
    return fa.flatMap(f)
}

public func >>=<K, A, B>(_ fa : MapKW<K, A>, _ f : @escaping (A) -> MapKW<K, B>) -> MapKW<K, B> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : Maybe<A>, _ f : @escaping (A) -> Maybe<B>) -> Maybe<B> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : NonEmptyList<A>, _ f : @escaping (A) -> NonEmptyList<B>) -> NonEmptyList<B> {
    return fa.flatMap(f)
}

public func >>=<A, B, C>(_ fa : Reader<A, B>, _ f : @escaping (B) -> Reader<A, C>) -> Reader<A, C> {
    return fa.flatMap(f)
}

public func >>=<A, B>(_ fa : Try<A>, _ f : @escaping (A) -> Try<B>) -> Try<B> {
    return fa.flatMap(f)
}

public func >>=<A, B, C>(_ fa : Free<A, B>, _ f : @escaping (B) -> Free<A, C>) -> Free<A, C> {
    return fa.flatMap(f)
}
