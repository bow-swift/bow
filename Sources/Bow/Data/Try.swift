import Foundation

public enum TryError : Error {
    case illegalState
    case predicateError(String)
    case unsupportedOperation(String)
}

public final class ForTry {}
public typealias TryOf<A> = Kind<ForTry, A>

public class Try<A>: TryOf<A> {
    public static func success(_ value: A) -> Try<A> {
        return Success<A>(value)
    }
    
    public static func failure(_ error: Error) -> Try<A> {
        return Failure<A>(error)
    }

    public static func raise(_ error: Error) -> Try<A> {
        return failure(error)
    }
    
    public static func invoke(_ f: () throws -> A) -> Try<A> {
        do {
            let result = try f()
            return success(result)
        } catch let error {
            return failure(error)
        }
    }
    
    public static func fix(_ fa: TryOf<A>) -> Try<A> {
        return fa as! Try<A>
    }
    
    public func fold<B>(_ fe: (Error) -> B, _ fa: (A) throws -> B) -> B {
        switch self {
            case let failure as Failure<A>: return fe(failure.error)
            case let success as Success<A>:
                do {
                    return try fa(success.value)
                } catch let error {
                    return fe(error)
                }
            default:
                fatalError("Try must only have Success or Failure cases")
        }
    }
    
    public func failed() -> Try<Error> {
        return fold(Try<Error>.success,
                    { _ in Try<Error>.failure(TryError.unsupportedOperation("Success.failed"))})
    }
    
    public func getOrElse(_ defaultValue: A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    public func recoverWith(_ f: (Error) -> Try<A>) -> Try<A> {
        return fold(f, Try.success)
    }
    
    public func recover(_ f: @escaping (Error) -> A) -> Try<A> {
        return fold(f >>> Try.success, Try.success)
    }
}

class Success<A>: Try<A> {
    fileprivate let value: A
    
    init(_ value: A) {
        self.value = value
    }
}

class Failure<A>: Try<A> {
    fileprivate let error: Error
    
    init(_ error: Error) {
        self.error = error
    }
}

extension Try: CustomStringConvertible {
    public var description : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value))" })
    }
}

extension Try: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value.debugDescription))" })
    }
}

extension ForTry: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForTry, A>, _ rhs: Kind<ForTry, A>) -> Bool where A : Equatable {
        let tl = Try.fix(lhs)
        let tr = Try.fix(rhs)
        return tl.fold({ aError in tr.fold({ bError in "\(aError)" == "\(bError)"}, constant(false))},
                       { a in tr.fold(constant(false), { b in a == b }) })
    }
}

extension ForTry: Functor {
    public static func map<A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> B) -> Kind<ForTry, B> {
        return Try.fix(fa).fold(Try.failure, Try.success <<< f)
    }
}

extension ForTry: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForTry, A> {
        return Try.success(a)
    }
}

extension ForTry: Selective {}

extension ForTry: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<ForTry, B>) -> Kind<ForTry, B> {
        let trya = Try<A>.fix(fa)
        return trya.fold(Try<B>.raise, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForTry, Either<A, B>>) -> Kind<ForTry, B> {
        return Try.fix(f(a)).fold(Try<B>.raise,
             { either in
                either.fold({ a in tailRecM(a, f)},
                            Try<B>.pure)
        })
    }
}

extension ForTry: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForTry, A> {
        return Try.failure(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForTry, A>, _ f: @escaping (Error) -> Kind<ForTry, A>) -> Kind<ForTry, A> {
        return Try.fix(fa).recoverWith({ e in Try.fix(f(e)) })
    }
}

extension ForTry: MonadError {}

extension ForTry: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForTry, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Try.fix(fa).fold(constant(b),
                                { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ForTry, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Try.fix(fa).fold(constant(b),
                                { a in f(a, b) })
    }
}

extension ForTry: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForTry, B>> {
        return Try.fix(fa).fold({ _ in G.pure(Try.raise(TryError.illegalState)) },
                                { a in G.map(f(a), { b in Try.invoke{ b } }) })
    }
}

