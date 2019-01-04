import Foundation

infix operator >>= : AdditionPrecedence

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : Function0<A>, _ f : @escaping (A) -> Function0<B>) -> Function0<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B, C>(_ fa : Function1<A, B>, _ f : @escaping (B) -> Function1<A, C>) -> Function1<A, C> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B, C>(_ fa : Either<A, B>, _ f : @escaping (B) -> Either<A, C>) -> Either<A, C> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : Eval<A>, _ f : @escaping (A) -> Eval<B>) -> Eval<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : Id<A>, _ f : @escaping (A) -> Id<B>) -> Id<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : ListK<A>, _ f : @escaping (A) -> ListK<B>) -> ListK<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<K, A, B>(_ fa : MapK<K, A>, _ f : @escaping (A) -> MapK<K, B>) -> MapK<K, B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : Option<A>, _ f : @escaping (A) -> Option<B>) -> Option<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : NonEmptyList<A>, _ f : @escaping (A) -> NonEmptyList<B>) -> NonEmptyList<B> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B, C>(_ fa : Reader<A, B>, _ f : @escaping (B) -> Reader<A, C>) -> Reader<A, C> {
    return fa.flatMap(f)
}

@available(*, deprecated, message: "Use flatMap instead.")
public func >>=<A, B>(_ fa : Try<A>, _ f : @escaping (A) -> Try<B>) -> Try<B> {
    return fa.flatMap(f)
}
