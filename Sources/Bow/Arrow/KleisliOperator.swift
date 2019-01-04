import Foundation

infix operator >=> : AdditionPrecedence

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> Function0<B>, _ g : @escaping (B) -> Function0<C>) -> (A) -> Function0<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C, D>(_ f : @escaping (A) -> Function1<D, B>, _ g : @escaping (B) -> Function1<D, C>) -> (A) -> Function1<D, C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C, D>(_ f : @escaping (A) -> Either<D, B>, _ g : @escaping (B) -> Either<D, C>) -> (A) -> Either<D, C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> Eval<B>, _ g : @escaping (B) -> Eval<C>) -> (A) -> Eval<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> Id<B>, _ g : @escaping (B) -> Id<C>) -> (A) -> Id<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> ListK<B>, _ g : @escaping (B) -> ListK<C>) -> (A) -> ListK<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C, D>(_ f : @escaping (A) -> MapK<D, B>, _ g : @escaping (B) -> MapK<D, C>) -> (A) -> MapK<D, C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> Option<B>, _ g : @escaping (B) -> Option<C>) -> (A) -> Option<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> NonEmptyList<B>, _ g : @escaping (B) -> NonEmptyList<C>) -> (A) -> NonEmptyList<C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C, D>(_ f : @escaping (A) -> Reader<D, B>, _ g : @escaping (B) -> Reader<D, C>) -> (A) -> Reader<D, C> {
    return { a in f(a) >>= g }
}

@available(*, deprecated, message: "Use Kleisli composition instead.")
public func >=><A, B, C>(_ f : @escaping (A) -> Try<B>, _ g : @escaping (B) -> Try<C>) -> (A) -> Try<C> {
    return { a in f(a) >>= g }
}
