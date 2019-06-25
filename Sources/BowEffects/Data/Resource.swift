import Bow

public final class ForResource {}
public final class ResourcePartial<F, E>: Kind2<ForResource, F, E> where F: Bracket, F.E == E {}
public typealias ResourceOf<F, E, A> = Kind<ResourcePartial<F, E>, A> where F: Bracket, F.E == E

public class Resource<F, E, A>: ResourceOf<F, E, A> where F: Bracket, F.E == E {
    public static func fix(_ value: ResourceOf<F, E, A>) -> Resource<F, E, A> {
        return value as! Resource<F, E, A>
    }
    
    public static func from(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A, ExitCase<E>) -> Kind<F, ()>) -> Resource<F, E, A> {
        return RegularResource(acquire, release)
    }
    
    public static func from(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A) -> Kind<F, ()>) -> Resource<F, E, A> {
        return RegularResource(acquire, release)
    }
    
    public func invoke<C>(_ use: @escaping (A) -> Kind<F, C>) -> Kind<F, C> {
        fatalError("Invoke must be implemented in subclasses")
    }
}

public postfix func ^<F: Bracket, E, A>(_ value: ResourceOf<F, E, A>) -> Resource<F, E, A> where F.E == E {
    return Resource.fix(value)
}

extension ResourcePartial: Functor {
    public static func map<A, B>(_ fa: ResourceOf<F, E, A>, _ f: @escaping (A) -> B) -> ResourceOf<F, E, B> {
        return fa.flatMap { a in pure(f(a)) }
    }
}

extension ResourcePartial: Applicative {
    public static func pure<A>(_ a: A) -> ResourceOf<F, E, A> {
        return RegularResource({ F.pure(a) }, { _, _ in F.pure(()) })
    }
}

extension ResourcePartial: Monad {
    public static func flatMap<A, B>(_ fa: ResourceOf<F, E, A>, _ f: @escaping (A) -> ResourceOf<F, E, B>) -> ResourceOf<F, E, B> {
        return BindResource<F, E, A, B>(fa, f)
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ResourceOf<F, E, Either<A, B>>) -> ResourceOf<F, E, B> {
        return f(a)^.flatMap { either in
            either.fold({ a in tailRecM(a, f)^ }, pure)
        }
    }
}

extension Resource where A: Semigroup {
    public func combine(_ other: Resource<F, E, A>) -> Resource<F, E, A> {
        return flatMap { r in other.map { r2 in r.combine(r2) }^ }^
    }
}

extension Resource where A: Monoid {
    public static func empty() -> Resource<F, E, A> {
        return pure(A.empty())^
    }
}

private class RegularResource<F: Bracket, E, A>: Resource<F, E, A> where F.E == E {
    fileprivate let acquire: () -> Kind<F, A>
    fileprivate let release: (A, ExitCase<E>) -> Kind<F, ()>
    
    public init(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A, ExitCase<E>) -> Kind<F, ()>) {
        self.acquire = acquire
        self.release = release
    }
    
    public convenience init(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A) -> Kind<F, ()>) {
        self.init(acquire, { a, _ in release(a) })
    }
    
    override func invoke<C>(_ use: @escaping (A) -> Kind<F, C>) -> Kind<F, C> {
        return acquire().bracketCase(release, use)
    }
}

private class BindResource<F: Bracket, E, A, B>: Resource<F, E, B> where F.E == E {
    private let resource: ResourceOf<F, E, A>
    private let f: (A) -> ResourceOf<F, E, B>
    
    init(_ resource: ResourceOf<F, E, A>, _ f: @escaping (A) -> ResourceOf<F, E, B>) {
        self.resource = resource
        self.f = f
    }
    
    override func invoke<C>(_ use: @escaping (B) -> Kind<F, C>) -> Kind<F, C> {
        return resource^.invoke { a in
            self.f(a)^.invoke(use)
        }
    }
}

public extension Kind {
    func asResource<E>() -> Resource<F, E, A> where F: Bracket, F.E == E {
        return RegularResource({ self }, { _ in F.pure(()) })
    }
}
