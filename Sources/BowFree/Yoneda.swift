import Foundation
import Bow

/// Witness for the Yoneda<F, A> data type. To be used in simulated Higher Kinded Types.
public final class ForYoneda {}

/// Partial application of the Yoneda type constructor, omitting the last parameter.
public final class YonedaPartial<F: Functor>: Kind<ForYoneda, F> {}

/// Higher Kinded Type alias to improve readability-
public typealias YonedaOf<F: Functor, A> = Kind<YonedaPartial<F>, A>

/// This type implements the covariant form of the Yoneda lemma, stating that F is naturally isomorphic to Yoneda<F>.
///
/// Yoneda can be viewed as the partial application of the `map` function, where the first argument is fixed:
///
/// `map :: (F<A>, (A) -> B) -> F<B>`
/// `Yoneda :: ((A) -> B) -> F<B>`
public final class Yoneda<F: Functor, A>: YonedaOf<F, A> {
    // forall b. (a -> b) -> f b
    internal let function: (@escaping (A) -> Any) -> Kind<F, Any>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Yoneda.
    public static func fix(_ fa: YonedaOf<F, A>) -> Yoneda<F, A> {
        fa as! Yoneda<F, A>
    }
    
    /// Lifts a value to a Yoneda value.
    ///
    /// - Parameter fa: Functorial value.
    /// - Returns: Yoneda value.
    public static func liftYoneda(_ fa: Kind<F, A>) -> Yoneda<F, A> {
        Yoneda { f in fa.map(f) }
    }
    
    /// Initializes a Yoneda value.
    ///
    /// - Parameter f: Function describing the natural isomorphism.
    public init(_ f: @escaping (@escaping (A) -> /*B*/Any) -> Kind<F, /*B*/Any>) {
        self.function = f
    }
    
    public func toCoyoneda() -> Coyoneda<F, A> {
        Coyoneda(pivot: lower(), f: id)
    }
    
    /// Applies a function to this Yoneda value.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A value in the functorial context wrapped in this Yoneda value.
    public func apply<B>(_ f: @escaping (A) -> B) -> Kind<F, B> {
        self.function(f).map { x in x as! B }
    }
    
    /// Obtains the value yielding the Yoneda isomorphism.
    ///
    /// - Returns: A value in the functorial context.
    public func lower() -> Kind<F, A> {
        apply(id)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Yoneda.
public postfix func ^<F, A>(_ fa: YonedaOf<F, A>) -> Yoneda<F, A> {
    Yoneda.fix(fa)
}

// MARK: Instance of Functor for Yoneda

extension YonedaPartial: Functor {
    public static func map<A, B>(
        _ fa: YonedaOf<F, A>,
        _ f: @escaping (A) -> B
    ) -> YonedaOf<F, B> {
        Yoneda { b in
            fa^.apply(b <<< f)
        }
    }
}

// MARK: Instance of Applicative for Yoneda

extension YonedaPartial: Applicative where F: Applicative {
    public static func pure<A>(_ a: A) -> YonedaOf<F, A> {
        Yoneda { f in F.pure(f(a)) }
    }
    
    public static func ap<A, B>(
        _ ff: YonedaOf<F, (A) -> B>,
        _ fa: YonedaOf<F, A>
    ) -> YonedaOf<F, B> {
        Yoneda<F, B> { b in
            ff^.apply { f in b <<< f }
                .ap(fa^.apply(id))
        }
    }
}

// MARK: Instance of Selective for Yoneda

extension YonedaPartial: Selective where F: Monad {}

// MARK: Instance of Monad for Yoneda

extension YonedaPartial: Monad where F: Monad {
    public static func flatMap<A, B>(
        _ fa: YonedaOf<F, A>,
        _ f: @escaping (A) -> YonedaOf<F, B>
    ) -> YonedaOf<F, B> {
        Yoneda<F, B> { b in
            fa^.apply(id).flatMap { a in
                f(a)^.apply(b)
            }
        }
    }
    
    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> YonedaOf<F, Either<A, B>>
    ) -> YonedaOf<F, B> {
        f(a).flatMap { either in
            either.fold(
                { a in tailRecM(a, f) },
                { b in pure(b) }
            )
        }
    }
}

// MARK: Instance of Comonad for Yoneda

extension YonedaPartial: Comonad where F: Comonad {
    public static func coflatMap<A, B>(
        _ fa: YonedaOf<F, A>,
        _ f: @escaping (YonedaOf<F, A>) -> B
    ) -> YonedaOf<F, B> {
        Yoneda<F, B> { b in
            fa^.apply(id).coflatMap { x in
                b(f(Yoneda.liftYoneda(x)))
            }
        }
    }
    
    public static func extract<A>(
        _ fa: YonedaOf<F, A>
    ) -> A {
        fa^.lower().extract()
    }
}

// MARK: Instance of EquatableK for Yoneda

extension YonedaPartial: EquatableK where F: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: YonedaOf<F, A>,
        _ rhs: YonedaOf<F, A>
    ) -> Bool {
        lhs^.lower() == rhs^.lower()
    }
}

// MARK: Instance of Foldable for Yoneda

extension YonedaPartial: Foldable where F: Foldable {
    public static func foldLeft<A, B>(
        _ fa: YonedaOf<F, A>,
        _ b: B,
        _ f: @escaping (B, A) -> B
    ) -> B {
        fa^.lower().foldLeft(b, f)
    }
    
    public static func foldRight<A, B>(
        _ fa: YonedaOf<F, A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>
    ) -> Eval<B> {
        fa^.lower().foldRight(b, f)
    }
}

// MARK: Instance of Traverse for Yoneda

extension YonedaPartial: Traverse where F: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: YonedaOf<F, A>,
        _ f: @escaping (A) -> Kind<G, B>
    ) -> Kind<G, YonedaOf<F, B>> {
        fa^.lower().traverse(f).map(Yoneda.liftYoneda)
    }
}
