import Foundation
import Bow

public final class ForCoyoneda {}
public final class CoyonedaPartial<F>: Kind<ForCoyoneda, F> {}
public typealias CoyonedaOf<F, A> = Kind<CoyonedaPartial<F>, A>

public class Coyoneda<F, A>: CoyonedaOf<F, A> {
    internal let pivot: Kind<F, /*B*/Any>
    internal let function: (/*B*/Any) -> A
    
    public init(
        _ pivot: Kind<F, Any>,
        _ function: @escaping (Any) -> A
    ) {
        self.pivot = pivot
        self.function = function
    }
    
    public static func fix(_ fa: CoyonedaOf<F, A>) -> Coyoneda<F, A> {
        fa as! Coyoneda<F, A>
    }
}

public extension Coyoneda where F: Functor {
    static func liftCoyoneda(_ fa: Kind<F, A>) -> Coyoneda<F, A> {
        Coyoneda(fa.map { a in a as Any }, { x in x as! A })
    }
    
    func lower() -> Kind<F, A> {
        self.pivot.map { a in self.function(a) }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Coyoneda.
public postfix func ^<F, A>(_ fa: CoyonedaOf<F, A>) -> Coyoneda<F, A> {
    Coyoneda.fix(fa)
}

// MARK: Instance of Functor for Coyoneda

extension CoyonedaPartial: Functor {
    public static func map<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> B
    ) -> CoyonedaOf<F, B> {
        Coyoneda<F, B>(fa^.pivot, f <<< fa^.function)
    }
}

// MARK: Instance of Applicative for Coyoneda

extension CoyonedaPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> CoyonedaOf<F, A> {
        Coyoneda.liftCoyoneda(F.pure(a))
    }
    
    public static func ap<A, B>(
        _ ff: CoyonedaOf<F, (A) -> B>,
        _ fa: CoyonedaOf<F, A>
    ) -> CoyonedaOf<F, B> {
        Coyoneda.liftCoyoneda(
            F.map(ff^.pivot, fa^.pivot) { f, a in
                ff^.function(f)(fa^.function(a))
            })
    }
}

// MARK: Instance of Selective for Coyoneda

extension CoyonedaPartial: Selective where F: Monad {}

// MARK: Instance of Monad for Coyoneda

extension CoyonedaPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> CoyonedaOf<F, B>
    ) -> CoyonedaOf<F, B> {
        Coyoneda.liftCoyoneda(
            fa^.pivot.flatMap { x in
                f(fa^.function(x))^.lower()
            })
    }
    
    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> CoyonedaOf<F, Either<A, B>>
    ) -> CoyonedaOf<F, B> {
        f(a).flatMap { either in
            either.fold(
                { a in tailRecM(a, f) },
                { b in pure(b) }
            )
        }
    }
}

// MARK: Instance of Comonad for Coyoneda

extension CoyonedaPartial: Comonad where F: Comonad {
    public static func coflatMap<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (CoyonedaOf<F, A>) -> B
    ) -> CoyonedaOf<F, B> {
        Coyoneda(
            fa^.pivot.coflatMap { x in
                f(Coyoneda(x, fa^.function))
            },
            { x in x as! B }
        )
    }
    
    public static func extract<A>(
        _ fa: CoyonedaOf<F, A>
    ) -> A {
        fa^.function(fa^.pivot.extract())
    }
}

// MARK: Instance of Foldable for Coyoneda

extension CoyonedaPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ b: B,
        _ f: @escaping (B, A) -> B
    ) -> B {
        fa^.pivot.foldLeft(b) { b, any in
            f(b, fa^.function(any))
        }
    }
    
    public static func foldRight<A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>
    ) -> Eval<B> {
        fa^.pivot.foldRight(b) { any, b in
            f(fa^.function(any), b)
        }
    }
}

// MARK: Instance of Traverse for Coyoneda

extension CoyonedaPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: CoyonedaOf<F, A>,
        _ f: @escaping (A) -> Kind<G, B>
    ) -> Kind<G, CoyonedaOf<F, B>> {
        fa^.pivot.traverse(f <<< fa^.function)
            .map(Coyoneda.liftCoyoneda)
    }
}
