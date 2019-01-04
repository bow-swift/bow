import Foundation

public class ForEither {}
public typealias EitherOf<A, B> = Kind2<ForEither, A, B>
public typealias EitherPartial<A> = Kind<ForEither, A>

public class Either<A, B> : EitherOf<A, B> {
    public static func left(_ a : A) -> Either<A, B> {
        return Left<A, B>(a)
    }
    
    public static func right(_ b : B) -> Either<A, B> {
        return Right<A, B>(b)
    }
    
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
    
    public static func fix(_ fa : EitherOf<A, B>) -> Either<A, B> {
        return fa as! Either<A, B>
    }
    
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
    
    public var isLeft : Bool {
        return fold(constant(true), constant(false))
    }
    
    public var isRight : Bool {
        return !isLeft
    }
    
    public var leftValue : A {
        return fold(id, { _ in fatalError("Attempted to obtain leftValue on a right instance") })
    }
    
    public var rightValue : B {
        return fold({ _ in fatalError("Attempted to obtain rightValue on a left instance") }, id)
    }
    
    public func foldLeft<C>(_ c : C, _ f : (C, B) -> C) -> C {
        return fold(constant(c), { b in f(c, b) })
    }
    
    public func foldRight<C>(_ c : Eval<C>, _ f : (B, Eval<C>) -> Eval<C>) -> Eval<C> {
        return fold(constant(c), { b in f(b, c) })
    }
    
    public func swap() -> Either<B, A> {
        return fold(Either<B, A>.right, Either<B, A>.left)
    }
    
    public func map<C>(_ f : (B) -> C) -> Either<A, C> {
        return fold(Either<A, C>.left,
                    { b in Either<A, C>.right(f(b)) })
    }
    
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Either<C, D> {
        return fold({ a in Either<C, D>.left(fa(a)) },
                    { b in Either<C, D>.right(fb(b)) })
    }
    
    public func ap<BB, C>(_ fb : Either<A, BB>) -> Either<A, C> where B == (BB) -> C {
        return flatMap(fb.map)
    }
    
    public func flatMap<C>(_ f : (B) -> Either<A, C>) -> Either<A, C> {
        return fold(Either<A, C>.left, f)
    }
    
    public func exists(_ predicate : (B) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    public func toOption() -> Option<B> {
        return fold(constant(Option<B>.none()), Option<B>.some)
    }
    
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constant(defaultValue), id)
    }
    
    public func filterOrElse(_ predicate : @escaping (B) -> Bool, _ defaultValue : A) -> Either<A, B> {
        return fold(Either<A, B>.left,
                    { b in predicate(b) ?
                        Either<A, B>.right(b) :
                        Either<A, B>.left(defaultValue) })
    }

    public func traverse<G, C, Appl>(_ f : (B) -> Kind<G, C>, _ applicative : Appl) -> Kind<G, Kind<EitherPartial<A>, C>> where Appl : Applicative, Appl.F == G {
        return fold({ a in applicative.pure(Either<A, C>.left(a)) },
                    { b in applicative.map(f(b), { c in Either<A, C>.right(c) }) })
    }
    
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

extension Either : CustomStringConvertible {
    public var description : String {
        return fold({ a in "Left(\(a))"},
                    { b in "Right(\(b))"})
    }
}

extension Either : CustomDebugStringConvertible where A : CustomDebugStringConvertible, B : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ a in "Left(\(a.debugDescription)"},
                    { b in "Right(\(b.debugDescription))"})
    }
}

public extension Either {
    public static func functor() -> EitherApplicative<A> {
        return EitherApplicative<A>()
    }
    
    public static func applicative() -> EitherApplicative<A> {
        return EitherApplicative<A>()
    }
    
    public static func monad() -> EitherMonad<A> {
        return EitherMonad<A>()
    }
    
    public static func applicativeError() -> EitherMonadError<A> {
        return EitherMonadError<A>()
    }
    
    public static func monadError() -> EitherMonadError<A> {
        return EitherMonadError<A>()
    }
    
    public static func foldable() -> EitherFoldable<A> {
        return EitherFoldable<A>()
    }
    
    public static func traverse() -> EitherTraverse<A> {
        return EitherTraverse<A>()
    }
    
    public static func semigroupK() -> EitherSemigroupK<A> {
        return EitherSemigroupK<A>()
    }
    
    public static func eq<EqL, EqR>(_ eql : EqL, _ eqr : EqR) -> EitherEq<A, B, EqL, EqR> {
        return EitherEq<A, B, EqL, EqR>(eql, eqr)
    }

    public static func bifunctor() -> EitherBifunctor<A, B> {
        return EitherBifunctor<A, B>()
    }
}

public class EitherBifunctor<A, B>: Bifunctor {
    public typealias F = ForEither

    public func bimap<A, B, C, D>(_ fab: Kind2<ForEither, A, B>, _ f1: @escaping (A) -> C, _ f2: @escaping (B) -> D) -> Kind2<ForEither, C, D> {
        return Either.fix(fab).bimap(f1, f2)
    }
}

public class EitherApplicative<C> : Applicative {
    public typealias F = EitherPartial<C>
    
    public func pure<A>(_ a: A) -> EitherOf<C, A> {
        return Either<C, A>.pure(a)
    }
    
    public func ap<A, B>(_ ff: EitherOf<C, (A) -> B>, _ fa: EitherOf<C, A>) -> EitherOf<C, B> {
        return Either.fix(ff).ap(Either.fix(fa))
    }
}

public class EitherMonad<C> : EitherApplicative<C>, Monad {
    public func flatMap<A, B>(_ fa: EitherOf<C, A>, _ f: @escaping (A) -> EitherOf<C, B>) -> EitherOf<C, B> {
        return Either.fix(fa).flatMap({ eca in Either.fix(f(eca)) })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> EitherOf<C, Either<A, B>>) -> EitherOf<C, B> {
        return Either<A, B>.tailRecM(a, f)
    }
}

public class EitherMonadError<C> : EitherMonad<C>, MonadError {
    public typealias E = C
    
    public func raiseError<A>(_ e: C) -> EitherOf<C, A> {
        return Either<C, A>.left(e)
    }
    
    public func handleErrorWith<A>(_ fa: EitherOf<C, A>, _ f: @escaping (C) -> EitherOf<C, A>) -> EitherOf<C, A> {
        return Either.fix(fa).fold(f, constant(Either.fix(fa)))
    }
}

public class EitherFoldable<C> : Foldable {
    public typealias F = EitherPartial<C>
    
    public func foldLeft<A, B>(_ fa: EitherOf<C, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Either.fix(fa).foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: EitherOf<C, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Either.fix(fa).foldRight(b, f)
    }
}

public class EitherTraverse<C> : EitherFoldable<C>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: EitherOf<C, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, EitherOf<C, B>> where G == Appl.F, Appl : Applicative {
        return Either.fix(fa).traverse(f, applicative)
    }
}

public class EitherSemigroupK<C> : SemigroupK {
    public typealias F = EitherPartial<C>
    
    public func combineK<A>(_ x: EitherOf<C, A>, _ y: EitherOf<C, A>) -> EitherOf<C, A> {
        return Either.fix(x).combineK(Either.fix(y))
    }
}

public class EitherEq<L, R, EqL, EqR> : Eq where EqL : Eq, EqL.A == L, EqR : Eq, EqR.A == R {
    public typealias A = EitherOf<L, R>
    private let eql : EqL
    private let eqr : EqR
    
    public init(_ eql : EqL, _ eqr : EqR) {
        self.eql = eql
        self.eqr = eqr
    }
    
    public func eqv(_ a: EitherOf<L, R>, _ b: EitherOf<L, R>) -> Bool {
        return Either.fix(a).fold({ aLeft  in Either.fix(b).fold({ bLeft in eql.eqv(aLeft, bLeft) }, constant(false)) },
                                 { aRight in Either.fix(b).fold(constant(false), { bRight in eqr.eqv(aRight, bRight) }) })
    }
}

extension Either : Equatable where A : Equatable, B : Equatable {
    public static func ==(lhs : Either<A, B>, rhs : Either<A, B>) -> Bool {
        return lhs.fold({ la in rhs.fold({ lb in la == lb }, constant(false)) },
                        { ra in rhs.fold(constant(false), { rb in ra == rb })})
    }
}
