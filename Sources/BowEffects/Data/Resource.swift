import Bow

public final class ForResource {}
public final class ResourcePartial<F: Bracket>: Kind<ForResource, F> {}
public typealias ResourceOf<F: Bracket, A> = Kind<ResourcePartial<F>, A>

public class Resource<F: Bracket, A>: ResourceOf<F, A> {
    public static func fix(_ value: ResourceOf<F, A>) -> Resource<F, A> {
        return value as! Resource<F, A>
    }
    
    public static func from(acquire: @escaping () -> Kind<F, A>, release: @escaping (A, ExitCase<F.E>) -> Kind<F, ()>) -> Resource<F, A> {
        return RegularResource(acquire, release)
    }
    
    public static func from(acquire: @escaping () -> Kind<F, A>, release: @escaping (A) -> Kind<F, ()>) -> Resource<F, A> {
        return RegularResource(acquire, release)
    }
    
    public func use<C>(_ f: @escaping (A) -> Kind<F, C>) -> Kind<F, C> {
        fatalError("use must be implemented in subclasses")
    }
}

public postfix func ^<F: Bracket, A>(_ value: ResourceOf<F, A>) -> Resource<F, A> {
    return Resource.fix(value)
}

extension ResourcePartial: Functor {
    public static func map<A, B>(_ fa: ResourceOf<F, A>, _ f: @escaping (A) -> B) -> ResourceOf<F, B> {
        return fa.flatMap { a in pure(f(a)) }
    }
}

extension ResourcePartial: Applicative {
    public static func pure<A>(_ a: A) -> ResourceOf<F, A> {
        return RegularResource({ F.pure(a) }, { _, _ in F.pure(()) })
    }
}

extension ResourcePartial: Monad {
    public static func flatMap<A, B>(_ fa: ResourceOf<F, A>, _ f: @escaping (A) -> ResourceOf<F, B>) -> ResourceOf<F, B> {
        return BindResource<F, A, B>(fa, f)
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ResourceOf<F, Either<A, B>>) -> ResourceOf<F, B> {
        return f(a)^.flatMap { either in
            either.fold({ a in tailRecM(a, f)^ }, pure)
        }
    }
}

extension Resource where A: Semigroup {
    public func combine(_ other: Resource<F, A>) -> Resource<F, A> {
        return flatMap { r in other.map { r2 in r.combine(r2) }^ }^
    }
}

extension Resource where A: Monoid {
    public static func empty() -> Resource<F, A> {
        return pure(A.empty())^
    }
}

private class RegularResource<F: Bracket, A>: Resource<F, A> {
    fileprivate let acquire: () -> Kind<F, A>
    fileprivate let release: (A, ExitCase<F.E>) -> Kind<F, ()>
    
    public init(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A, ExitCase<F.E>) -> Kind<F, ()>) {
        self.acquire = acquire
        self.release = release
    }
    
    public convenience init(_ acquire: @escaping () -> Kind<F, A>, _ release: @escaping (A) -> Kind<F, ()>) {
        self.init(acquire, { a, _ in release(a) })
    }
    
    override func use<C>(_ f: @escaping (A) -> Kind<F, C>) -> Kind<F, C> {
        return acquire().bracketCase(release, f)
    }
}

private class BindResource<F: Bracket, A, B>: Resource<F, B> {
    private let resource: ResourceOf<F, A>
    private let f: (A) -> ResourceOf<F, B>
    
    init(_ resource: ResourceOf<F, A>, _ f: @escaping (A) -> ResourceOf<F, B>) {
        self.resource = resource
        self.f = f
    }
    
    override func use<C>(_ f: @escaping (B) -> Kind<F, C>) -> Kind<F, C> {
        return resource^.use { a in
            self.f(a)^.use(f)
        }
    }
}

public extension Kind where F: Bracket {
    var asResource: Resource<F, A> {
        return RegularResource({ self }, { _ in F.pure(()) })
    }
}
