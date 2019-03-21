import Foundation

public final class ForConst {}
public final class ConstPartial<A>: Kind<ForConst, A> {}
public typealias ConstOf<A, T> = Kind<ConstPartial<A>, T>

public final class Const<A, T>: ConstOf<A, T> {
    public let value: A

    public static func fix(_ fa: ConstOf<A, T>) -> Const<A, T> {
        return fa as! Const<A, T>
    }
    
    public init(_ value: A) {
        self.value = value
    }
    
    public func retag<U>() -> Const<A, U> {
        return Const<A, U>(value)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Const.
public postfix func ^<A, T>(_ fa: ConstOf<A, T>) -> Const<A, T> {
    return Const.fix(fa)
}

extension Const: CustomStringConvertible {
    public var description : String {
        return "Const(\(value))"
    }
}

extension Const: CustomDebugStringConvertible where A: CustomDebugStringConvertible{
    public var debugDescription: String {
        return "Const(\(value.debugDescription))"
    }
}

extension ConstPartial: EquatableK where A: Equatable {
    public static func eq<T>(_ lhs: Kind<ConstPartial<A>, T>, _ rhs: Kind<ConstPartial<A>, T>) -> Bool where T: Equatable {
        return Const.fix(lhs).value == Const.fix(rhs).value
    }
}

extension ConstPartial: Functor {
    public static func map<C, B>(_ fa: Kind<ConstPartial<A>, C>, _ f: @escaping (C) -> B) -> Kind<ConstPartial<A>, B> {
        return Const.fix(fa).retag()
    }
}

extension ConstPartial: Applicative where A: Monoid {
    public static func pure<C>(_ a: C) -> Kind<ConstPartial<A>, C> {
        return Const<A, C>(A.empty())
    }

    public static func ap<C, B>(_ ff: Kind<ConstPartial<A>, (C) -> B>, _ fa: Kind<ConstPartial<A>, C>) -> Kind<ConstPartial<A>, B> {
        let cf: Const<A, B> = Const.fix(ff).retag()
        let ca: Const<A, B> = Const.fix(fa).retag()
        return cf.combine(ca)
    }
}

extension ConstPartial: Foldable {
    public static func foldLeft<C, B>(_ fa: Kind<ConstPartial<A>, C>, _ b: B, _ f: @escaping (B, C) -> B) -> B {
        return b
    }

    public static func foldRight<C, B>(_ fa: Kind<ConstPartial<A>, C>, _ b: Eval<B>, _ f: @escaping (C, Eval<B>) -> Eval<B>) -> Eval<B> {
        return b
    }
}

extension ConstPartial: Traverse {
    public static func traverse<G: Applicative, C, B>(_ fa: Kind<ConstPartial<A>, C>, _ f: @escaping (C) -> Kind<G, B>) -> Kind<G, Kind<ConstPartial<A>, B>> {
        return G.pure(Const.fix(fa).retag())
    }
}

extension ConstPartial: FunctorFilter {}

extension ConstPartial: TraverseFilter {
    public static func traverseFilter<C, B, G: Applicative>(_ fa: Kind<ConstPartial<A>, C>, _ f: @escaping (C) -> Kind<G, Kind<ForOption, B>>) -> Kind<G, Kind<ConstPartial<A>, B>> {
        return G.pure(Const.fix(fa).retag())
    }

    public static func mapFilter<C, B>(_ fa: Kind<ConstPartial<A>, C>, _ f: @escaping (C) -> Kind<ForOption, B>) -> Kind<ConstPartial<A>, B> {
        return traverseFilter(fa, { a in Id<OptionOf<B>>.pure(f(a)) }).extract()
    }
}

extension Const: Semigroup where A: Semigroup {
    public func combine(_ other : Const<A, T>) -> Const<A, T> {
        return Const<A, T>(self.value.combine(other.value))
    }
}

extension Const: Monoid where A: Monoid {
    public static func empty() -> Const<A, T> {
        return Const(A.empty())
    }
}
