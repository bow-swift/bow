import Foundation

/// An ApplicativeError is an `Applicative` that has capabilities to raise and handle error values.
///
/// It has an associated type `E` to represent the error type that the implementing instance is able to handle.
public protocol ApplicativeError: Applicative {
    /// Error type associated to this `ApplicativeError` instance
    associatedtype E

    /// Lifts an error to the context implementing this instance.
    ///
    /// - Parameter e: A value of the error type.
    /// - Returns: A value representing the error in the context implementing this instance.
    static func raiseError<A>(_ e: E) -> Kind<Self, A>

    /// Handles an error, potentially recovering from it by mapping it to a value in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - fa: A computation that may have an error.
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    static func handleErrorWith<A>(_ fa: Kind<Self, A>, _ f: @escaping (E) -> Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Related functions

public extension ApplicativeError {
    /// Handles an error, potentially recovering from it by mapping it to a value.
    ///
    /// - Parameters:
    ///   - fa: A computation that may have an error.
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    static func handleError<A>(_ fa: Kind<Self, A>, _ f: @escaping (E) -> A) -> Kind<Self, A> {
        return handleErrorWith(fa, { a in self.pure(f(a)) })
    }

    /// Handles errors by converting them into `Either` values in the context implementing this instance.
    ///
    /// - Parameter fa: A computation that may have an error.
    /// - Returns: An either wrapped in the context implementing this instance.
    static func attempt<A>(_ fa: Kind<Self, A>) -> Kind<Self, Either<E, A>> {
        return handleErrorWith(map(fa, Either<E, A>.right), { e in self.pure(Either<E, A>.left(e)) })
    }

    /// Converts an `Either` value into a value in the context implementing this instance.
    ///
    /// - Parameter fea: An `Either` value.
    /// - Returns: A value in the context implementing this instance.
    static func fromEither<A>(_ fea: Either<E, A>) -> Kind<Self, A> {
        return fea.fold(raiseError, pure)
    }
    
    /// Converts an `Option` value into a value in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - oa: An `Option` value.
    ///   - f: A function providing the error value in case the option is empty.
    /// - Returns: A value in the context implementing this instance.
    static func fromOption<A>(_ oa: Option<A>, _ f: () -> E) -> Kind<Self, A> {
        return oa.fold({ Self.raiseError(f()) }, Self.pure)
    }
    
    /// Converts a `Try` value into a value in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - ta: A `Try` value.
    ///   - f: A function transforming the error contained in `Try` to the error type of this instance.
    /// - Returns: A value in the context implementing this instance.
    static func fromTry<A>(_ ta: Try<A>, _ f: (Error) -> E) -> Kind<Self, A> {
        return ta.fold({ e in Self.raiseError(f(e)) }, Self.pure)
    }

    /// Evaluates a throwing function, catching and mapping errors.
    ///
    /// - Parameters:
    ///   - f: A throwing function.
    ///   - recover: A function that maps from `Error` to the type that this instance is able to handle.
    /// - Returns: A value in the context implementing this instance.
    static func catchError<A>(_ f: () throws -> A, _ recover: (Error) -> E) -> Kind<Self, A> {
        do {
            return pure(try f())
        } catch {
            return raiseError(recover(error))
        }
    }

    /// Evaluates a throwing function, catching errors.
    ///
    /// - Parameter f: A throwing function.
    /// - Returns: A value in the context implementing this instance.
    static func catchError<A>(_ f: () throws -> A) -> Kind<Self, A> where Self.E == Error {
        do {
            return pure(try f())
        } catch {
            return raiseError(error)
        }
    }
}

// MARK: Syntax for ApplicativeError

public extension Kind where F: ApplicativeError {
    /// Lifts an error to the context implementing this instance.
    ///
    /// This is a convenience method to call `ApplicativeError.raiseError` as a static method of this type.
    ///
    /// - Parameter e: A value of the error type.
    /// - Returns: A value representing the error in the context implementing this instance.
    static func raiseError(_ e: F.E) -> Kind<F, A> {
        return F.raiseError(e)
    }

    /// Handles an error, potentially recovering from it by mapping it to a value in the context implementing this instance.
    ///
    /// This is a convenience method to call `ApplicativeError.handleErrorWith` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    func handleErrorWith(_ f: @escaping (F.E) -> Kind<F, A>) -> Kind<F, A> {
        return F.handleErrorWith(self, f)
    }

    /// Handles an error, potentially recovering from it by mapping it to a value.
    ///
    /// This is a convenience method to call `ApplicativeError.handleError` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    func handleError(_ f: @escaping (F.E) -> A) -> Kind<F, A> {
        return F.handleError(self, f)
    }

    /// Handles errors by converting them into `Either` values in the context implementing this instance.
    ///
    /// This is a convenience method to call `ApplicativeError.attempt` as an instance method of this type.
    ///
    /// - Returns: An either wrapped in the context implementing this instance.
    func attempt() -> Kind<F, Either<F.E, A>> {
        return F.attempt(self)
    }

    /// Converts an `Either` value into a value in the context implementing this instance.
    ///
    /// This is a convenience method to call `ApplicativeError.fromEither` as a static method of this type.
    ///
    /// - Parameter fea: An `Either` value.
    /// - Returns: A value in the context implementing this instance.
    static func fromEither(_ fea: Either<F.E, A>) -> Kind<F, A> {
        return F.fromEither(fea)
    }

    /// Converts an `Option` value into a value in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - oa: An `Option` value.
    ///   - f: A function providing the error value in case the option is empty.
    /// - Returns: A value in the context implementing this instance.
    static func fromOption(_ oa: Option<A>, _ f: () -> F.E) -> Kind<F, A> {
        return F.fromOption(oa, f)
    }

    /// Converts a `Try` value into a value in the context implementing this instance.
    ///
    /// - Parameters:
    ///   - ta: A `Try` value.
    ///   - f: A function transforming the error contained in `Try` to the error type of this instance.
    /// - Returns: A value in the context implementing this instance.
    static func fromTry(_ ta: Try<A>, _ f: (Error) -> F.E) -> Kind<F, A> {
        return F.fromTry(ta, f)
    }
    
    /// Evaluates a throwing function, catching and mapping errors.
    ///
    /// This is a convenience method to call `ApplicativeError.catchError` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: A throwing function.
    ///   - recover: A function that maps from `Error` to the type that this instance is able to handle.
    /// - Returns: A value in the context implementing this instance.
    static func catchError(_ f: () throws -> A, _ recover: (Error) -> F.E) -> Kind<F, A> {
        return F.catchError(f, recover)
    }
}

public extension Kind where F: ApplicativeError, F.E == Error {
    /// Evaluates a throwing function, catching errors.
    ///
    /// This is a convenience method to call `ApplicativeError.catchError` as a static method of this type.
    ///
    /// - Parameter f: A throwing function.
    /// - Returns: A value in the context implementing this instance.
    static func catchError(_ f: () throws -> A) -> Kind<F, A> {
        return F.catchError(f)
    }
}
