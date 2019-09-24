import Bow

/// Witness for the `Resource<F, A>` type. To be used in simulated Higher Data Types.
public final class ForResource {}

/// Partial application of the Resource type constructor, omitting the last parameter.
public final class ResourcePartial<F: Bracket>: Kind<ForResource, F> {}

/// Higher Kinded Type alias to improve readability of Kind<ResourcePartial<F>, A>
public typealias ResourceOf<F: Bracket, A> = Kind<ResourcePartial<F>, A>

/// Resource models resource allocation and releasing. It is specially useful when multiple resources that depend on each other need to be acquired and later released in reverse order. Whn a resource is created, one can make use of the `use` method to run a computation with the resource. The finalizers are guaranteed to run afterwards in reverse order of acquisition.
public class Resource<F: Bracket, A>: ResourceOf<F, A> {
    /// Safe downcast.
    ///
    /// - Parameter value: Value in higher kinded form.
    /// - Returns: Value casted to Resource.
    public static func fix(_ value: ResourceOf<F, A>) -> Resource<F, A> {
        return value as! Resource<F, A>
    }
    
    /// Initializes a resource.
    ///
    /// - Parameters:
    ///   - acquire: Function to acquire the resource.
    ///   - release: Function to release the resource.
    /// - Returns: A Resource that will run the provided functions to acquire and release it.
    public static func from(acquire: @escaping () -> Kind<F, A>, release: @escaping (A, ExitCase<F.E>) -> Kind<F, ()>) -> Resource<F, A> {
        return RegularResource(acquire, release)
    }
    
    /// Uses the resource.
    ///
    /// - Parameter f: Function to use the resource.
    /// - Returns: Result of using the resource.
    public func use<C>(_ f: @escaping (A) -> Kind<F, C>) -> Kind<F, C> {
        fatalError("use must be implemented in subclasses")
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher kinded form.
/// - Returns: Value casted to Resource.
public postfix func ^<F: Bracket, A>(_ value: ResourceOf<F, A>) -> Resource<F, A> {
    return Resource.fix(value)
}

// MARK: Instance of `Functor` for `Resource`
extension ResourcePartial: Functor {
    public static func map<A, B>(_ fa: ResourceOf<F, A>, _ f: @escaping (A) -> B) -> ResourceOf<F, B> {
        return fa.flatMap { a in pure(f(a)) }
    }
}

// MARK: Instance of `Applicative` for `Resource`
extension ResourcePartial: Applicative {
    public static func pure<A>(_ a: A) -> ResourceOf<F, A> {
        return RegularResource({ F.pure(a) }, { _, _ in F.pure(()) })
    }
}

// MARK: Instance of `Monad` for `Resource`
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

// MARK: Instance of `Semigroup` for `Resource`
extension Resource where A: Semigroup {
    public func combine(_ other: Resource<F, A>) -> Resource<F, A> {
        return flatMap { r in other.map { r2 in r.combine(r2) }^ }^
    }
}

// MARK: Instance of `Monoid` for `Resource`
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
        return acquire().bracketCase(release: release, use: f)
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

// Syntax for `Resource`
public extension Kind where F: Bracket {
    /// Converts this computation into a Resource.
    var asResource: Resource<F, A> {
        return RegularResource({ self }, { _ in F.pure(()) })
    }
}
