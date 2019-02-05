import Foundation

/**
 Witness for the `Either<A, B>` data type. To be used in simulated Higher Kinded Types.
 */
public final class ForEither {}

/**
 Parial application of the Either type constructor, omitting the last parameter.

 The following statements are equivalent:

 ```swift
 EitherOf<A, B> == Kind2<ForEither, A, B> == Kind<EitherPartial<A>, B>
 ```
 */
public final class EitherPartial<A>: Kind<ForEither, A> {}

/**
 Higher Kinded Type alias to improve readability over `Kind2<ForEither, A, B>`
 */
public typealias EitherOf<A, B> = Kind<EitherPartial<A>, B>

/**
 Sum type of types `A` and `B`. Represents a value of either one of those types, but not both at the same time. Values of type `A` are called `left`; values of type `B` are called right.
 */
public class Either<A, B> : EitherOf<A, B> {
    /**
     Constructs a left value given an instance of `A`.
     */
    public static func left(_ a : A) -> Either<A, B> {
        return Left<A, B>(a)
    }
    
    /**
     Constructs a right value given an instance of `B`.
     */
    public static func right(_ b : B) -> Either<A, B> {
        return Right<A, B>(b)
    }
    
    /**
     Lifts a value to the `Either` context. It is equivalen to `Either<A, B>.right`.
     */
    public static func pure(_ b : B) -> Either<A, B> {
        return right(b)
    }
    
    public static func tailRecM<C>(_ a : A, _ f : (A) -> Kind<EitherPartial<C>, Either<A, B>>) -> Either<C, B> {
        return Either<C, Either<A, B>>.fix(f(a)).fold(Either<C, B>.left,
            { either in
                either.fold({ left in tailRecM(left, f)},
                            Either<C, B>.right)
            })
    }
    
    /**
     Safe downcast to `Either<A, B>`.
     */
    public static func fix(_ fa : EitherOf<A, B>) -> Either<A, B> {
        return fa as! Either<A, B>
    }
    
    /**
     Applies the provided closures based on the content of this `Either` value.
     
     - parameter fa: Closure to apply if the contained value in this `Either` is of type `A`.
     - parameter fb: Closure to apply if the contained value in this `Either` is of type `B`.
     - returns: Result of applying the corresponding closure to this value.
     */
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C) -> C {
        switch self {
            case is Left<A, B>:
                return (self as! Left<A, B>).a |> fa
            case is Right<A, B>:
                return (self as! Right<A, B>).b |> fb
            default:
                fatalError("Either must only have left and right cases")
        }
    }
    
    /**
     Checks if this value belongs to the left type.
     */
    public var isLeft : Bool {
        return fold(constant(true), constant(false))
    }
    
    /**
     Checks if this value belongs to the right type.
     */
    public var isRight : Bool {
        return !isLeft
    }
    
    /**
     Attempts to obtain a value of the left type.
     
     This propery is unsafe and can cause fatal errors if it is invoked on a right value.
     */
    public var leftValue : A {
        return fold(id, { _ in fatalError("Attempted to obtain leftValue on a right instance") })
    }
    
    /**
     Attempts to obtain a value of the right type.
     
     This property is unsafe and can cause fatal errors if it is invoked on a left value.
     */
    public var rightValue : B {
        return fold({ _ in fatalError("Attempted to obtain rightValue on a left instance") }, id)
    }
    
    /**
     Left associative fold given a function.
     */
    public func foldLeft<C>(_ c : C, _ f : (C, B) -> C) -> C {
        return fold(constant(c), { b in f(c, b) })
    }
    
    /**
     Right associative fold given a function.
     */
    public func foldRight<C>(_ c : Eval<C>, _ f : (B, Eval<C>) -> Eval<C>) -> Eval<C> {
        return fold(constant(c), { b in f(b, c) })
    }
    
    /**
     Reverses the types of this either. Left values become right values and vice versa.
     */
    public func swap() -> Either<B, A> {
        return fold(Either<B, A>.right, Either<B, A>.left)
    }
    
    /**
     Transforms the right type parameter, preserving its structure.
     
     - parameter f: Closure to be applied when there is a right value.
     */
    public func map<C>(_ f : (B) -> C) -> Either<A, C> {
        return fold(Either<A, C>.left,
                    { b in Either<A, C>.right(f(b)) })
    }
    
    /**
     Transforms both type parameters, preserving its structure.
     
     - parameter fa: Closure to be applied when there is a left value.
     - parameter fb: Closure to be applied when there is a right value.
     */
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Either<C, D> {
        return fold({ a in Either<C, D>.left(fa(a)) },
                    { b in Either<C, D>.right(fb(b)) })
    }
    
    /**
     Transforms the parameter using the function wrapped in the receiver `Either`.
     */
    public func ap<BB, C>(_ fb : Either<A, BB>) -> Either<A, C> where B == (BB) -> C {
        return flatMap(fb.map)
    }
    
    /**
     Returns the result of applying `f` to this value if it is a right value, or the left value otherwise.
     */
    public func flatMap<C>(_ f : (B) -> Either<A, C>) -> Either<A, C> {
        return fold(Either<A, C>.left, f)
    }
    
    /**
     Checks if the right value of this `Either` matches the provided predicate.
     */
    public func exists(_ predicate : (B) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    /**
     Converts this `Either` to an `Option`.
     
     This conversion is lossy. Left values are mapped to `Option.none()` and right values to `Option.some()`. The original `Either cannot be reconstructed from the output of this conversion.
     */
    public func toOption() -> Option<B> {
        return fold(constant(Option<B>.none()), Option<B>.some)
    }
    
    /**
     Obtains the value wrapped if it is a right value, or the default value provided as an argument.
     */
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constant(defaultValue), id)
    }
    
    /**
     Filters the right values, providing a default left value if the do not match the provided predicate.
     */
    public func filterOrElse(_ predicate : @escaping (B) -> Bool, _ defaultValue : A) -> Either<A, B> {
        return fold(Either<A, B>.left,
                    { b in predicate(b) ?
                        Either<A, B>.right(b) :
                        Either<A, B>.left(defaultValue) })
    }

    /**
     Given a function which returns a `G` effect, thread this effect through the running of this function on the wrapped value, returning an Either in a `G` context.
     */
    public func traverse<G, C, Appl>(_ f : (B) -> Kind<G, C>, _ applicative : Appl) -> Kind<G, Kind<EitherPartial<A>, C>> where Appl : Applicative, Appl.F == G {
        return fold({ a in applicative.pure(Either<A, C>.left(a)) },
                    { b in applicative.map(f(b), { c in Either<A, C>.right(c) }) })
    }
    
    /**
     Combines this `Either` with the provided as an argument. If this is a left value, the result is the provided value. Otherwise, the receiver is returned.
     */
    public func combineK(_ y : Either<A, B>) -> Either<A, B> {
        return fold(constant(y), Either<A, B>.right)
    }
}

class Left<A, B> : Either<A, B> {
    let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class Right<A, B> : Either<A, B> {
    let b : B
    
    init(_ b : B) {
        self.b = b
    }
}

// MARK: Protocol conformances

extension Either: Fixed {}

/// Conformance of `Either` to `CustomStringConvertible`
extension Either : CustomStringConvertible {
    public var description : String {
        return fold({ a in "Left(\(a))"},
                    { b in "Right(\(b))"})
    }
}

/// Conformance of `Either` to `CustomDebugStringConvertible`, provided that both of its type arguments conform to `CustomDebugStringConvertible`.
extension Either : CustomDebugStringConvertible where A : CustomDebugStringConvertible, B : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ a in "Left(\(a.debugDescription)"},
                    { b in "Right(\(b.debugDescription))"})
    }
}

/// Conformance of `Either` to `Equatable`, provided that both of its type arguments conform to `Equatable`.
extension Either : Equatable where A : Equatable, B : Equatable {
    public static func ==(lhs : Either<A, B>, rhs : Either<A, B>) -> Bool {
        return lhs.fold({ la in rhs.fold({ lb in la == lb }, constant(false)) },
                        { ra in rhs.fold(constant(false), { rb in ra == rb })})
    }
}

// MARK: Either typeclass instances
public extension Either {
    /**
     Obtains an instance of the `Functor` typeclass for `Either`.
     */
    public static func functor() -> ApplicativeInstance<A> {
        return ApplicativeInstance<A>()
    }
    
    /**
     Obtains an instance of the `Applicative` typeclass for `Either`.
     */
    public static func applicative() -> ApplicativeInstance<A> {
        return ApplicativeInstance<A>()
    }
    
    /**
     Obtains an instance of the `Monad` typeclass for `Either`.
     */
    public static func monad() -> MonadInstance<A> {
        return MonadInstance<A>()
    }
    
    /**
     Obtains an instance of the `ApplicativeError` typeclass for `Either`.
     */
    public static func applicativeError() -> MonadErrorInstance<A> {
        return MonadErrorInstance<A>()
    }
    
    /**
     Obtains an instance of the `MonadError` typeclass for `Either`.
     */
    public static func monadError() -> MonadErrorInstance<A> {
        return MonadErrorInstance<A>()
    }
    
    /**
     Obtains an instance of the `Foldable` typeclass for `Either`.
     */
    public static func foldable() -> FoldableInstance<A> {
        return FoldableInstance<A>()
    }
    
    /**
     Obtains an instance of the `Traverse` typeclass for `Either`.
     */
    public static func traverse() -> TraverseInstance<A> {
        return TraverseInstance<A>()
    }
    
    /**
     Obtains an instance of the `SemigroupK` typeclass for `Either`.
     */
    public static func semigroupK() -> SemigroupKInstance<A> {
        return SemigroupKInstance<A>()
    }
    
    /**
     Obtains an instance of the `Eq` typeclass for `Either`, given there exists instances of `Eq` for its type arguments.
     */
    public static func eq<EqL, EqR>(_ eql : EqL, _ eqr : EqR) -> EqInstance<A, B, EqL, EqR> {
        return EqInstance<A, B, EqL, EqR>(eql, eqr)
    }

    /**
     Obtains an instance of the `Bifunctor` typeclass for `Either`.
     */
    /* public static func bifunctor() -> BifunctorInstance<A, B> {
        return BifunctorInstance<A, B>()
    }*/

    /**
     An instance of the `Bifunctor` typeclass for the `Either` data type.
     */
    /* public class BifunctorInstance<A, B>: Bifunctor {
        public typealias F = ForEither

        public func bimap<A, B, C, D>(_ fab: EitherOf<A, B>, _ f1: @escaping (A) -> C, _ f2: @escaping (B) -> D) -> EitherOf<C, D> {
            return Either<A, B>.fix(fab).bimap(f1, f2)
        }
    }*/


    /**
     An instance of the `Applicative` typeclass for the `Either` data type.
     */
    public class ApplicativeInstance<C> : Applicative {
        public typealias F = EitherPartial<C>
        
        public func pure<A>(_ a: A) -> EitherOf<C, A> {
            return Either<C, A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: EitherOf<C, (A) -> B>, _ fa: EitherOf<C, A>) -> EitherOf<C, B> {
            return Either<C, (A) -> B>.fix(ff).ap(Either<C, A>.fix(fa))
        }
    }

    /**
     An instance of the `Monad` typeclass for the `Either` data type.
     */
    public class MonadInstance<C> : ApplicativeInstance<C>, Monad {
        public func flatMap<A, B>(_ fa: EitherOf<C, A>, _ f: @escaping (A) -> EitherOf<C, B>) -> EitherOf<C, B> {
            return Either<C, A>.fix(fa).flatMap({ eca in Either<C, B>.fix(f(eca)) })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> EitherOf<C, Either<A, B>>) -> EitherOf<C, B> {
            return Either<A, B>.tailRecM(a, f)
        }
    }

    /**
     An instance of the `MonadError` typeclass for the `Either` data type.
     */
    public class MonadErrorInstance<C> : MonadInstance<C>, MonadError {
        public typealias E = C
        
        public func raiseError<A>(_ e: C) -> EitherOf<C, A> {
            return Either<C, A>.left(e)
        }
        
        public func handleErrorWith<A>(_ fa: EitherOf<C, A>, _ f: @escaping (C) -> EitherOf<C, A>) -> EitherOf<C, A> {
            return Either<C, A>.fix(fa).fold(f, constant(Either<C, A>.fix(fa)))
        }
    }

    /**
     An instance of the `Foldable` typeclass for the `Either` data type.
     */
    public class FoldableInstance<C> : Foldable {
        public typealias F = EitherPartial<C>
        
        public func foldLeft<A, B>(_ fa: EitherOf<C, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return Either<C, A>.fix(fa).foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: EitherOf<C, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return Either<C, A>.fix(fa).foldRight(b, f)
        }
    }

    /**
     An instance of the `Traverse` typeclass for the `Either` data type.
     */
    public class TraverseInstance<C> : FoldableInstance<C>, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: EitherOf<C, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, EitherOf<C, B>> where G == Appl.F, Appl : Applicative {
            return Either<C, A>.fix(fa).traverse(f, applicative)
        }
    }

    /**
     An instance of the `SemigroupK` typeclass for the `Either` data type.
     */
    public class SemigroupKInstance<C> : SemigroupK {
        public typealias F = EitherPartial<C>
        
        public func combineK<A>(_ x: EitherOf<C, A>, _ y: EitherOf<C, A>) -> EitherOf<C, A> {
            return Either<C, A>.fix(x).combineK(Either<C, A>.fix(y))
        }
    }

    /**
     An instance of the `Eq` typeclass for the `Either` data type.
     */
    public class EqInstance<L, R, EqL, EqR> : Eq where EqL : Eq, EqL.A == L, EqR : Eq, EqR.A == R {
        public typealias A = EitherOf<L, R>
        private let eql : EqL
        private let eqr : EqR
        
        init(_ eql : EqL, _ eqr : EqR) {
            self.eql = eql
            self.eqr = eqr
        }
        
        public func eqv(_ a: EitherOf<L, R>, _ b: EitherOf<L, R>) -> Bool {
            return Either<L, R>.fix(a).fold(
                { aLeft in Either<L, R>.fix(b).fold({ bLeft in eql.eqv(aLeft, bLeft) }, constant(false)) },
                { aRight in Either<L, R>.fix(b).fold(constant(false), { bRight in eqr.eqv(aRight, bRight) }) })
        }
    }
}
