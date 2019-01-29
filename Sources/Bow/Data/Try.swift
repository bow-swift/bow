import Foundation

/// Represents the common error conditions of operating `Try`.
///
/// - illegalState: Thrown with a not expected state.
/// - predicateError: Thrown to indicate that the predicate failed with the detailed message.
/// - unsupportedOperation: Thrown to indicate that the requested operation is not supported.
public enum TryError : Error {
    case illegalState
    case predicateError(String)
    case unsupportedOperation(String)
}

/// Witness for the `Try<A>` data type. To be used in simulated Higher Kinded Types.
public class ForTry {}

/// Higher Kinded Type alias to improve readability of `Kind<ForTry, A>`.
public typealias TryOf<A> = Kind<ForTry, A>

/// Represents a computation that can result in an `A` or in an exception if something has gone wrong.
public class Try<A> : TryOf<A> {
    
    /// Constructs a success value given an instance of `A`.
    ///
    /// - Parameter value: Instance of `A`.
    /// - Returns: `Try` instance with a valid value.
    public static func success(_ value : A) -> Try<A> {
        return Success<A>(value)
    }
    
    /// Constructs an exception given an error.
    ///
    /// - Parameter error: Instance of `Error`.
    /// - Returns: `Try` instance with an exception.
    public static func failure(_ error : Error) -> Try<A> {
        return Failure<A>(error)
    }
    
    /// Lifts a value to the `Try` context. It is equivalent to `Try<A>.success`.
    ///
    /// - Parameter value: Instance of `A`.
    /// - Returns: `Try` instance with a success value of type `A`.
    public static func pure(_ value : A) -> Try<A> {
        return success(value)
    }
    
    /// Lifts an exception to the `Try` context. It is equivalent to `Try<A>.failure`.
    ///
    /// - Parameter error: Instance of `Error`.
    /// - Returns: Instance of `Try`.
    public static func raise(_ error : Error) -> Try<A> {
        return failure(error)
    }
    
    /// Lifts a throwing function to the functional context `Bow.Try`.
    ///
    /// - Parameter f: Throwing Function.
    /// - Returns: Instance of `Try`.
    public static func invoke(_ f : () throws -> A) -> Try<A> {
        do {
            let result = try f()
            return success(result)
        } catch let error {
            return failure(error)
        }
    }
    
    /// Assuming you had unlimited stack space must return the same result that you would get
    /// if you recursively called `f` until you got a `Right` value.
    ///
    /// - Parameters:
    ///   - a: An initial value for applying `f`.
    ///   - f: Recursive step that takes `A` returning a `Either` in `Try` context.
    ///   - left: `Left` value to apply `f`.
    /// - Returns: Result of applying the corresponding closure to `A` recursively.
    public static func tailRecM<B>(_ a : A, _ f : (_ left: A) -> Try<Either<A, B>>) -> Try<B> {
        return f(a).fold(Try<B>.raise,
                         { either in
                            either.fold({ a in tailRecM(a, f)},
                                        Try<B>.pure)
                         })
    }
    
    /// Safe downcast to `Try<A>` from higher kinded type of `Try`.
    ///
    /// - Parameter fa: Instance of higher kinded type of Try.
    /// - Returns: Instance of `Try`.
    public static func fix(_ fa : TryOf<A>) -> Try<A> {
        return fa.fix()
    }
    
    /// Applies the provided closures based on the content of this `Try`.
    ///
    /// - Parameters:
    ///   - fe: Closure for transforming a failure into a new value.
    ///   - error: Given exception instances `Error`.
    ///   - fa: Closure to transform the success value into a new one.
    ///   - a: The success value of this `Try`.
    /// - Returns: Result of applying the corresponding closure to this value.
    public func fold<B>(_ fe : (_ error: Error) -> B, _ fa : (_ a: A) throws -> B) -> B {
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
    
    /// Left associative fold given a function.
    ///
    /// - Parameters:
    ///   - b: An initial value for applying fold.
    ///   - f: Closure for combine the success value of `Try` with `b` into a new one.
    ///   - a: Instance of `A`. The success value of this `Try`.
    /// - Returns: Result of applying `f` to this `Try` in combine `b`.
    public func foldLeft<B>(_ b : B, _ f : (_ b: B, _ a: A) -> B) -> B {
        return fold(constant(b),
                    { a in f(b, a) })
    }
    
    /// Right associative fold given a function.
    ///
    /// - Parameters:
    ///   - lb: An initial value for applying fold in a lazy way.
    ///   - f: Closure for combine the success value of `Try` with `lb` into a new one.
    ///   - a: Instance of `A`. The success value of this `Try`.
    /// - Returns: Result of applying `f` to this `Try` in combine `lb`.
    public func foldRight<B>(_ lb : Eval<B>, _ f : (_ a: A, _ lb: Eval<B>) -> Eval<B>) -> Eval<B> {
        return fold(constant(lb),
                    { a in f(a, lb) })
    }
    
    /// Given a function which returns a `G` effect, thread this effect through the running
    /// of this function on the wrapped value, returning a `Try` in a `G` context.
    ///
    /// - Parameters:
    ///   - f: Closure to transform an `A` in `G[B]` where `G` is `Applicative`.
    ///   - a: Instance of `A`. The success value of this `Try`.
    ///   - applicative: Applicate for `G`.
    /// - Returns: Return a `Try` in a `G` context.
    public func traverse<G, B, Appl>(_ f : (_ a: A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, TryOf<B>> where Appl : Applicative, Appl.F == G {
        return fold({ _ in applicative.pure(Try<B>.raise(TryError.illegalState)) },
                    { a in applicative.map(f(a), { b in Try<B>.invoke{ b } }) })
    }
    
    /// Transforms the success parameter, preserving its structure.
    ///
    /// - Parameter f: A closure that takes the `success` value of the instance.
    /// - Returns: The result of the given closure. If this instance is an exception,
    ///   returns `raise` of exception in `B` context.
    public func map<B>(_ f : @escaping (A) -> B) -> Try<B> {
        return fold(Try<B>.raise, f >>> Try<B>.pure)
    }
    
    /// Transforms the success parameter, preserving its structure.
    ///
    /// Use the `flatMap` method with a closure that returns a `Try`.
    ///
    /// - Parameter f: A closure that takes the `success` value of the instance.
    /// - Parameter a: The success value of this `Try`.
    /// - Returns: The result of the given closure. If this instance is an exception,
    ///   returns `raise` of exception in `B` context.
    public func flatMap<B>(_ f : (_ a: A) -> Try<B>) -> Try<B> {
        return fold(Try<B>.raise, f)
    }
    
    /// Transforms the parameter using the closure wrapped in the receiver `Try`.
    ///
    /// - Parameter fa: `Try` where success value is a closure `(A) -> B`
    /// - Returns: The result of the given closure wrapped.
    public func ap<AA, B>(_ fa : Try<AA>) -> Try<B> where A == (AA) -> B {
        return flatMap(fa.map)
    }

    /// Filters the success value for receiver `Try`.
    ///
    /// - Parameter predicate: Predicate to validate the success value in receiver `Try`.
    /// - Parameter a: The success value of this `Try`.
    /// - Returns: A new `Try` with success value in case match with the provided predicate.
    public func filter(_ predicate : (_ a: A) -> Bool) -> Try<A> {
        return fold(Try.raise,
                    { a in predicate(a) ?
                        Try<A>.pure(a) :
                        Try<A>.raise(TryError.predicateError("Predicate does not hold for \(a)"))
                    })
    }
    
    /// Transforms this `Try` to failed `Try`. If this `Try` has success value will be mapped to
    /// default exception `.unsupportedOperation` in another case will be the success case of this
    /// new one `Try<Error>`.
    ///
    ///     enum Exception: Error {
    ///         case invalid
    ///     }
    ///     Try<String>.success("Example").failed()  // Failure(.unsupportedOperation)
    ///     Try<Exception>.failure(invalid).failed() // Success(invalid)
    ///
    /// - Returns: Result transforms to `Try<Error>`.
    public func failed() -> Try<Error> {
        return fold(Try<Error>.success,
                    { _ in Try<Error>.failure(TryError.unsupportedOperation("Success.failed"))})
    }
    
    /// Obtains the value wrapped if it is a `success` value, or the provided value.
    ///
    /// - Parameter defaultValue: default value provided.
    /// - Returns: The wrapped value in case `Try` has a valid value or default value provided in other case.
    public func getOrElse(_ defaultValue : A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    /// Transforms the failure `Try` to a success `Try`, preserving its structure.
    ///
    /// - Parameter f: A closure that takes the `failure` value of the instance.
    /// - Parameter e: The failure value of this `Try`.
    /// - Returns: The result of the given closure. If this instance is a success value,
    ///   returns it directly without apply `f`.
    public func recover(_ f : @escaping (_ e: Error) -> A) -> Try<A> {
        return fold(f >>> Try.success, Try.success)
    }
    
    /// Transforms the failure `Try` to a success `Try`, preserving its structure.
    ///
    /// Use the `recoverWith` method with a closure that returns a `Try`. In other case
    /// use `recover`.
    ///
    /// - Parameter f: A closure that takes the `failure` value of the instance.
    /// - Parameter e: The failure value of this `Try`.
    /// - Returns: The result of the given closure. If this instance is a success value,
    ///   returns it directly without apply `f`.
    public func recoverWith(_ f : (_ e: Error) -> Try<A>) -> Try<A> {
        return fold(f, Try.success)
    }
    
    /// Applies the provided closures based on the content of this `Try`.
    ///
    /// Use the `transform` method with a closure that returns a `Try`. In other case
    /// you should use `fold`.
    ///
    /// - Parameters:
    ///   - fe: Closure for transforming a failure into a new value.
    ///   - e: Given exception instances `Error`.
    ///   - fa: Closure to transform the success value into a new one.
    ///   - a: The success value of this `Try`.
    /// - Returns: Result of applying the corresponding closure to this value.
    public func transform(failure : (_ e: Error) -> Try<A>, success : (_ a: A) -> Try<A>) -> Try<A> {
        return fold(failure, { _ in flatMap(success) })
    }
}

// MARK: Class definition for `Try`'s values.

/// Represents a success value in an `A` context for `Try`.
class Success<A> : Try<A> {
    fileprivate let value : A
    
    init(_ value : A) {
        self.value = value
    }
}

/// Represents a failure value for `Try`.
class Failure<A> : Try<A> {
    fileprivate let error : Error
    
    init(_ error : Error) {
        self.error = error
    }
}

// MARK: Protocol conformances

/// Conformance of `Try` to `CustomStringConvertible`.
extension Try : CustomStringConvertible {
    public var description : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value))" })
    }
}

/// Conformance of `Try` to `CustomDebugStringConvertible`, provided that success argument conforms to `CustomDebugStringConvertible`.
extension Try : CustomDebugStringConvertible where A : CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value.debugDescription))" })
    }
}

/// Conformance of `Try` to `Equatable`, provided that success/failure arguments conform to `Equatable`.
extension Try : Equatable where A : Equatable {
    public static func ==(lhs : Try<A>, rhs : Try<A>) -> Bool {
        return lhs.fold({ aError in rhs.fold({ bError in "\(aError)" == "\(bError)"}, constant(false))},
                        { a in rhs.fold(constant(false), { b in a == b }) })
    }
}

// MARK: Kind extensions

public extension Kind where F == ForTry {
    
    /// Safe downcast to `Try<A>` from higher kinded type of `Try`.
    ///
    /// - Returns: Instance of `Try`.
    public func fix() -> Try<A> {
        return self as! Try<A>
    }
}

// MARK: Try typeclass instances

public extension Try {
    
    /// Obtains an instance of `Functor` typeclass for `Try`.
    ///
    /// - Returns: Instance of `FunctorInstance`.
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    /// Obtains an instance of `Applicative` typeclass for `Try`.
    ///
    /// - Returns: Instance of `ApplicativeInstance`.
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    /// Obtains an instance of `Monad` typeclass for `Try`.
    ///
    /// - Returns: Instance of `MonadInstance`.
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    /// Obtains an instance of `ApplicativeError` typeclass for `Try`.
    ///
    /// - Returns: Instance of `ApplicativeErrorInstance`.
    public static func applicativeError<E>() -> ApplicativeErrorInstance<E> {
        return ApplicativeErrorInstance<E>()
    }
    
    /// Obtains an instance of `MonadError` typeclass for `Try`.
    ///
    /// - Returns: Instance of `MonadErrorInstance`
    public static func monadError<E>() -> MonadErrorInstance<E> {
        return MonadErrorInstance<E>()
    }
    
    /// Obtains an instance of `Eq` typeclass for `Try`.
    ///
    /// - Parameter eqa: Instance of `Eq` for its type argument.
    /// - Returns: Instance of `EqInstance`.
    public static func eq<EqA>(_ eqa : EqA) -> EqInstance<A, EqA> {
        return EqInstance<A, EqA>(eqa)
    }
    
    /// Obtains an instance of the `Foldable` typeclass for `Try`.
    ///
    /// - Returns: Instance of `FoldableInstance`.
    public static func foldable() -> FoldableInstance {
        return FoldableInstance()
    }
    
    /// Obtains an instance of the `Traverse` typeclass for `Try`.
    ///
    /// - Returns: Instance of `TraverseInstance`.
    public static func traverse() -> TraverseInstance {
        return TraverseInstance()
    }
    
    /// An instance of `Functor` typeclass for the `Try` data type.
    public class FunctorInstance: Functor {
        public typealias F = ForTry
        
        public func map<A, B>(_ fa: TryOf<A>, _ f: @escaping (A) -> B) -> TryOf<B> {
            return fa.fix().map(f)
        }
    }
    
    /// An instance of `Applicative` typeclass for the `Try` data type.
    public class ApplicativeInstance: FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> TryOf<A> {
            return Try<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: TryOf<(A) -> B>, _ fa: TryOf<A>) -> TryOf<B> {
            return ff.fix().ap(fa.fix())
        }
    }
    
    /// An instance of `Monad` typeclass for the `Try` data type.
    public class MonadInstance: ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: TryOf<A>, _ f: @escaping (A) -> TryOf<B>) -> TryOf<B> {
            return fa.fix().flatMap({ a in f(a).fix() })
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> TryOf<Either<A, B>>) -> TryOf<B> {
            return Try<A>.tailRecM(a, { a in f(a).fix() })
        }
    }
    
    /// An instance of `MonadError` typeclass for the `Try` data type.
    public class MonadErrorInstance<C>: MonadInstance, MonadError where C : Error {
        public typealias E = C
        
        public func raiseError<A>(_ e: C) -> TryOf<A> {
            return Try<A>.failure(e)
        }
        
        public func handleErrorWith<A>(_ fa: TryOf<A>, _ f: @escaping (C) -> TryOf<A>) -> TryOf<A> {
            return fa.fix().recoverWith({ e in f(e as! C).fix() })
        }
    }
    
    /// An instance of `ApplicativeError` typeclass for the `Try` data type.
    public class ApplicativeErrorInstance<C>: ApplicativeInstance, ApplicativeError where C : Error {
        public typealias E = C
        
        public func raiseError<A>(_ e: C) -> TryOf<A> {
            return Try<A>.monadError().raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: TryOf<A>, _ f: @escaping (C) -> TryOf<A>) -> TryOf<A> {
            return Try<A>.monadError().handleErrorWith(fa, f)
        }
    }
    
    /// An instance of `Eq` typeclass for the `Try` data type.
    public class EqInstance<R, EqR> : Eq where EqR : Eq, EqR.A == R {
        public typealias A = TryOf<R>
        private let eqr : EqR
        
        init(_ eqr : EqR) {
            self.eqr = eqr
        }
        
        public func eqv(_ a: TryOf<R>, _ b: TryOf<R>) -> Bool {
            let a = Try<R>.fix(a)
            let b = Try<R>.fix(b)
            return a.fold({ aError in b.fold({ bError in "\(aError)" == "\(bError)" }, constant(false))},
                          { aSuccess in b.fold(constant(false), { bSuccess in eqr.eqv(aSuccess, bSuccess)})})
        }
    }
    
    /// An instance of `Foldable` typeclass for the `Try` data type.
    public class FoldableInstance : Foldable {
        public typealias F = ForTry
        
        public func foldLeft<A, B>(_ fa: Kind<ForTry, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: Kind<ForTry, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }
    
    /// An instance of `Traverse` typeclass for the `Try` data type.
    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ForTry, B>> where G == Appl.F, Appl : Applicative {
            return fa.fix().traverse(f, applicative)
        }
    }
}
