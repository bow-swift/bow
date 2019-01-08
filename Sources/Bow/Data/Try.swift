import Foundation

public enum TryError : Error {
    case illegalState
    case predicateError(String)
    case unsupportedOperation(String)
}

public class ForTry {}
public typealias TryOf<A> = Kind<ForTry, A>

public class Try<A> : TryOf<A> {
    public static func success(_ value : A) -> Try<A> {
        return Success<A>(value)
    }
    
    public static func failure(_ error : Error) -> Try<A> {
        return Failure<A>(error)
    }
    
    public static func pure(_ value : A) -> Try<A> {
        return success(value)
    }
    
    public static func raise(_ error : Error) -> Try<A> {
        return failure(error)
    }
    
    public static func invoke(_ f : () throws -> A) -> Try<A> {
        do {
            let result = try f()
            return success(result)
        } catch let error {
            return failure(error)
        }
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Try<Either<A, B>>) -> Try<B> {
        return f(a).fold(Try<B>.raise,
                         { either in
                            either.fold({ a in tailRecM(a, f)},
                                        Try<B>.pure)
                         })
    }
    
    public static func fix(_ fa : TryOf<A>) -> Try<A> {
        return fa.fix()
    }
    
    public func fold<B>(_ fe : (Error) -> B, _ fa : (A) throws -> B) -> B {
        switch self {
            case is Failure<A>:
                return fe((self as! Failure).error)
            case is Success<A>:
                do {
                    return try fa((self as! Success).value)
                } catch let error {
                    return fe(error)
                }
            default:
                fatalError("Try must only have Success or Failure cases")
        }
    }
    
    public func foldLeft<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold(constant(b),
                    { a in f(b, a) })
    }
    
    public func foldRight<B>(_ lb : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fold(constant(lb),
                    { a in f(a, lb) })
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, TryOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ _ in applicative.pure(Try<B>.raise(TryError.illegalState)) },
                    { a in applicative.map(f(a), { b in Try<B>.invoke{ b } }) })
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Try<B> {
        return fold(Try<B>.raise, f >>> Try<B>.pure)
    }
    
    public func flatMap<B>(_ f : (A) -> Try<B>) -> Try<B> {
        return fold(Try<B>.raise, f)
    }
    
    public func ap<AA, B>(_ fa : Try<AA>) -> Try<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }
    
    public func filter(_ predicate : (A) -> Bool) -> Try<A> {
        return fold(Try.raise,
                    { a in predicate(a) ?
                        Try<A>.pure(a) :
                        Try<A>.raise(TryError.predicateError("Predicate does not hold for \(a)"))
                    })
    }
    
    public func failed() -> Try<Error> {
        return fold(Try<Error>.success,
                    { _ in Try<Error>.failure(TryError.unsupportedOperation("Success.failed"))})
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    public func recoverWith(_ f : (Error) -> Try<A>) -> Try<A> {
        return fold(f, Try.success)
    }
    
    public func recover(_ f : @escaping (Error) -> A) -> Try<A> {
        return fold(f >>> Try.success, Try.success)
    }
    
    public func transform(failure : (Error) -> Try<A>, success : (A) -> Try<A>) -> Try<A> {
        return fold(failure, { _ in flatMap(success) })
    }
}

class Success<A> : Try<A> {
    fileprivate let value : A
    
    init(_ value : A) {
        self.value = value
    }
}

class Failure<A> : Try<A> {
    fileprivate let error : Error
    
    init(_ error : Error) {
        self.error = error
    }
}

extension Try : CustomStringConvertible {
    public var description : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value))" })
    }
}

extension Try : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value.debugDescription))" })
    }
}

public extension Kind where F == ForTry {
    public func fix() -> Try<A> {
        return self as! Try<A>
    }
}

public extension Try {
    public static func functor() -> TryFunctor {
        return TryFunctor()
    }
    
    public static func applicative() -> TryApplicative {
        return TryApplicative()
    }
    
    public static func monad() -> TryMonad {
        return TryMonad()
    }
    
    public static func applicativeError<E>() -> TryMonadError<E> {
        return TryMonadError<E>()
    }
    
    public static func monadError<E>() -> TryMonadError<E> {
        return TryMonadError<E>()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> TryEq<A, EqA> {
        return TryEq<A, EqA>(eqa)
    }
    
    public static func foldable() -> TryFoldable {
        return TryFoldable()
    }
    
    public static func traverse() -> TryTraverse {
        return TryTraverse()
    }
}

public class TryFunctor : Functor {
    public typealias F = ForTry
    
    public func map<A, B>(_ fa: TryOf<A>, _ f: @escaping (A) -> B) -> TryOf<B> {
        return fa.fix().map(f)
    }
}

public class TryApplicative : TryFunctor, Applicative {
    public func pure<A>(_ a: A) -> TryOf<A> {
        return Try<A>.pure(a)
    }
    
    public func ap<A, B>(_ ff: TryOf<(A) -> B>, _ fa: TryOf<A>) -> TryOf<B> {
        return ff.fix().ap(fa.fix())
    }
}

public class TryMonad : TryApplicative, Monad {
    public func flatMap<A, B>(_ fa: TryOf<A>, _ f: @escaping (A) -> TryOf<B>) -> TryOf<B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> TryOf<Either<A, B>>) -> TryOf<B> {
        return Try<A>.tailRecM(a, { a in f(a).fix() })
    }
}

public class TryMonadError<C> : TryMonad, MonadError where C : Error{
    public typealias E = C
    
    public func raiseError<A>(_ e: C) -> TryOf<A> {
        return Try<A>.failure(e)
    }
    
    public func handleErrorWith<A>(_ fa: TryOf<A>, _ f: @escaping (C) -> TryOf<A>) -> TryOf<A> {
        return fa.fix().recoverWith({ e in f(e as! C).fix() })
    }
}

public class TryEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = TryOf<R>
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: TryOf<R>, _ b: TryOf<R>) -> Bool {
        let a = Try.fix(a)
        let b = Try.fix(b)
        return a.fold({ aError in b.fold({ bError in "\(aError)" == "\(bError)" }, constant(false))},
                      { aSuccess in b.fold(constant(false), { bSuccess in eqr.eqv(aSuccess, bSuccess)})})
    }
}

public class TryFoldable : Foldable {
    public typealias F = ForTry
    
    public func foldLeft<A, B>(_ fa: Kind<ForTry, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldRight<A, B>(_ fa: Kind<ForTry, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class TryTraverse : TryFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ForTry, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

extension Try : Equatable where A : Equatable {
    public static func ==(lhs : Try<A>, rhs : Try<A>) -> Bool {
        return lhs.fold({ aError in rhs.fold({ bError in "\(aError)" == "\(bError)"}, constant(false))},
                        { a in rhs.fold(constant(false), { b in a == b }) })
    }
}
