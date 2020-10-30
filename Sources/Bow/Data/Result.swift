public extension Result {
    
    /// Converts this Result into an Either value.
    ///
    /// - Returns: An Either.left if this is a Result.failure, or an Either.right if this is a Result.success
    func toEither() -> Either<Failure, Success> {
        fold(Either.left, Either.right)
    }

    /// Converts this Result into a Try value.
    ///
    /// - Returns: A Try.failure if this is a Result.failure, or a Try.success if this is a Result.success
    func toTry() -> Try<Success> {
        fold(Try.failure, Try.success)
    }
    
    /// Converts this Result into a Validated value.
    ///
    /// - Returns: A Validated.invalid if this is a Result.failure, or a Validated.valid if this is a Result.success.
    func toValidated() -> Validated<Failure, Success> {
        fold(Validated.invalid, Validated.valid)
    }
    
    /// Converts this Result into a ValidatedNEA value.
    ///
    /// - Returns: A Validated.invalid with a NonEmptyArray of the Failure type if this is a Result.failure, or a Validated.valid if this is a Result.success.
    func toValidatedNEA() -> ValidatedNEA<Failure, Success> {
        toValidated().toValidatedNEA()
    }

    /// Converts this Result into an Option value.
    ///
    /// - Returns: Option.none if this is a Result.failure, or Option.some if this is a Result.success.
    func toOption() -> Option<Success> {
        fold(constant(Option.none()), Option.some)
    }

    /// Applies the corresponding closure based on the value contained in this result.
    ///
    /// - Parameters:
    ///   - ifFailure: Closure to be applied if this is a Result.failure.
    ///   - ifSuccess: Closure to be applied if this is a Result.success.
    /// - Returns: Output of the execution of the corresponding closure, based on the internal value of this Result.
    func fold<B>(_ ifFailure: @escaping (Failure) -> B,
                 _ ifSuccess: @escaping (Success) -> B) -> B {
        switch self {
        case let .failure(error): return ifFailure(error)
        case let .success(value): return ifSuccess(value)
        }
    }
}

// MARK: Conversion to Result when the left type conforms to Error

public extension Either where A: Error {
    /// Converts this Either into a Result value.
    ///
    /// - Returns: A Result.success if this is an Either.right, or a Result.failure if this is an Either.left.
    func toResult() -> Result<B, A> {
        self.fold(Result.failure, Result.success)
    }
}

// MARK: Conversion to Result when the invalid type conforms to Error

public extension Validated where E: Error {
    /// Converts this Validated into a Result value.
    ///
    /// - Returns: A Result.success if this is a Validated.valid, or a Result.failure if this is a Validated.invalid.
    func toResult() -> Result<A, E> {
        self.fold(Result.failure, Result.success)
    }
}

// MARK: Conversion to Result

public extension Try {
    /// Converts this Try into a Result value.
    ///
    /// - Returns: A Result.success if this is a Try.success, or a Result.failure if this is a Try.failure.
    func toResult() -> Result<A, Error> {
        self.fold(Result.failure, Result.success)
    }
}

// MARK: Functor methods for Result

public extension Result {
    /// Given a function, provides a new function lifted to the context of this type.
    ///
    /// - Parameter f: Function to be lifted.
    /// - Returns: Function in the context of this type.
    static func lift<B>(_ f: @escaping (Success) -> B) -> (Result<Success, Failure>) -> Result<B, Failure> {
        { result in result.map(f) }
    }
    
    /// Transforms the value type with a constant value.
    ///
    /// - Parameters:
    ///   - b: Constant value to replace the value type.
    /// - Returns: A new value with the structure of the original value, with its value type transformed.
    func `as`<B>(_ b: B) -> Result<B, Failure> {
        self.map(constant(b))
    }
    
    /// Replaces the value type by the `Void` type.
    ///
    /// - Returns: New value in this context, with `Void` as value type, preserving the original structure.
    func void() -> Result<Void, Failure> {
        self.as(())
    }
    
    /// Transforms the value type and pairs it with its original value.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: A pair with the original value and its transformation, with the structure of the original value.
    func product<B>(_ f: @escaping (Success) -> B) -> Result<(Success, B), Failure> {
        self.map { a in (a, f(a)) }
    }
    
    /// Transforms the value type by making a tuple with a new constant value to the left of the original value type.
    ///
    /// - Parameters:
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    func tupleLeft<B>(_ b: B) -> Result<(B, Success), Failure> {
        self.map { a in (b, a) }
    }
    
    /// Transforms the value type by making a tuple with a new constant value to the right of the original value type.
    ///
    /// - Parameters:
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    func tupleRight<B>(_ b: B) -> Result<(Success, B), Failure> {
        self.map { a in (a, b) }
    }
}

// MARK: Applicative methods for Result

public extension Result {
    /// Lifts a value to the this context type.
    ///
    /// - Parameter wrapped: Value to be lifted.
    /// - Returns: Provided value in this context type.
    static func pure(_ wrapped: Success) -> Result<Success, Failure> {
        .success(wrapped)
    }
    
    /// Creates a tuple out of two values in this context.
    ///
    /// - Parameters:
    ///   - fa: 1st value of the tuple.
    ///   - fb: 2nd value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>
    ) -> Result<(A, B), Failure> where Success == (A, B) {
        switch (fa, fb) {
            
        case (.success(let a), .success(let b)):
            return .success((a, b))
            
        case (.failure(let l), _),
             (_, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of three values in this context.
    ///
    /// - Parameters:
    ///   - fa: 1st value of the tuple.
    ///   - fb: 2nd value of the tuple.
    ///   - fc: 3rd value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>
    ) -> Result<(A, B, C), Failure> where Success == (A, B, C) {
        switch (fa, fb, fc) {
            
        case (.success(let a), .success(let b), .success(let c)):
            return .success((a, b, c))
            
        case (.failure(let l), _, _),
             (_, .failure(let l), _),
             (_, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of four values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>
    ) -> Result<(A, B, C, D), Failure> where Success == (A, B, C, D) {
        switch (fa, fb, fc, fd) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d)):
            return .success((a, b, c, d))
            
        case (.failure(let l), _, _, _),
             (_, .failure(let l), _, _),
             (_, _, .failure(let l), _),
             (_, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of five values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D, E>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>
    ) -> Result<(A, B, C, D, E), Failure> where Success == (A, B, C, D, E) {
        switch (fa, fb, fc, fd, fe) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d), .success(let e)):
            return .success((a, b, c, d, e))
            
        case (.failure(let l), _, _, _, _),
             (_, .failure(let l), _, _, _),
             (_, _, .failure(let l), _, _),
             (_, _, _, .failure(let l), _),
             (_, _, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of six values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - f: 6th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D, E, F>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>
    ) -> Result<(A, B, C, D, E, F), Failure> where Success == (A, B, C, D, E, F) {
        switch (fa, fb, fc, fd, fe, ff) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d), .success(let e), .success(let f)):
            return .success((a, b, c, d, e, f))
            
        case (.failure(let l), _, _, _, _, _),
             (_, .failure(let l), _, _, _, _),
             (_, _, .failure(let l), _, _, _),
             (_, _, _, .failure(let l), _, _),
             (_, _, _, _, .failure(let l), _),
             (_, _, _, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of seven values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - f: 6th value of the tuple.
    ///   - g: 7th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D, E, F, G>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>
    ) -> Result<(A, B, C, D, E, F, G), Failure> where Success == (A, B, C, D, E, F, G) {
        switch (fa, fb, fc, fd, fe, ff, fg) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d), .success(let e), .success(let f), .success(let g)):
            return .success((a, b, c, d, e, f, g))
            
        case (.failure(let l), _, _, _, _, _, _),
             (_, .failure(let l), _, _, _, _, _),
             (_, _, .failure(let l), _, _, _, _),
             (_, _, _, .failure(let l), _, _, _),
             (_, _, _, _, .failure(let l), _, _),
             (_, _, _, _, _, .failure(let l), _),
             (_, _, _, _, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of eight values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - f: 6th value of the tuple.
    ///   - g: 7th value of the tuple.
    ///   - h: 8th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D, E, F, G, H>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>,
        _ fh: Result<H, Failure>
    ) -> Result<(A, B, C, D, E, F, G, H), Failure> where Success == (A, B, C, D, E, F, G, H) {
        switch (fa, fb, fc, fd, fe, ff, fg, fh) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d), .success(let e), .success(let f), .success(let g), .success(let h)):
            return .success((a, b, c, d, e, f, g, h))
            
        case (.failure(let l), _, _, _, _, _, _, _),
             (_, .failure(let l), _, _, _, _, _, _),
             (_, _, .failure(let l), _, _, _, _, _),
             (_, _, _, .failure(let l), _, _, _, _),
             (_, _, _, _, .failure(let l), _, _, _),
             (_, _, _, _, _, .failure(let l), _, _),
             (_, _, _, _, _, _, .failure(let l), _),
             (_, _, _, _, _, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Creates a tuple out of nine values in this context.
    ///
    /// - Parameters:
    ///   - a: 1st value of the tuple.
    ///   - b: 2nd value of the tuple.
    ///   - c: 3rd value of the tuple.
    ///   - d: 4th value of the tuple.
    ///   - e: 5th value of the tuple.
    ///   - f: 6th value of the tuple.
    ///   - g: 7th value of the tuple.
    ///   - h: 8th value of the tuple.
    ///   - i: 9th value of the tuple.
    /// - Returns: A tuple in this context.
    static func zip<A, B, C, D, E, F, G, H, I>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>,
        _ fh: Result<H, Failure>,
        _ fi: Result<I, Failure>
    ) -> Result<(A, B, C, D, E, F, G, H, I), Failure> where Success == (A, B, C, D, E, F, G, H, I) {
        switch (fa, fb, fc, fd, fe, ff, fg, fh, fi) {
            
        case (.success(let a), .success(let b), .success(let c), .success(let d), .success(let e), .success(let f), .success(let g), .success(let h), .success(let i)):
            return .success((a, b, c, d, e, f, g, h, i))
            
        case (.failure(let l), _, _, _, _, _, _, _, _),
             (_, .failure(let l), _, _, _, _, _, _, _),
             (_, _, .failure(let l), _, _, _, _, _, _),
             (_, _, _, .failure(let l), _, _, _, _, _),
             (_, _, _, _, .failure(let l), _, _, _, _),
             (_, _, _, _, _, .failure(let l), _, _, _),
             (_, _, _, _, _, _, .failure(let l), _, _),
             (_, _, _, _, _, _, _, .failure(let l), _),
             (_, _, _, _, _, _, _, _, .failure(let l)):
            return .failure(l)
        }
    }
    
    /// Combines the result of two computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ f: @escaping (A, B) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B), Failure>.zip(fa, fb).map(f)
    }
    
    /// Combines the result of three computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ f: @escaping (A, B, C) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C), Failure>.zip(fa, fb, fc).map(f)
    }
    
    /// Combines the result of four computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ f: @escaping (A, B, C, D) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D), Failure>.zip(fa, fb, fc, fd).map(f)
    }
    
    /// Combines the result of five computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D, E>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ f: @escaping (A, B, C, D, E) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D, E), Failure>.zip(fa, fb, fc, fd, fe).map(f)
    }
    
    /// Combines the result of six computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - ff: 6th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D, E, F>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ f: @escaping (A, B, C, D, E, F) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D, E, F), Failure>.zip(fa, fb, fc, fd, fe, ff).map(f)
    }
    
    /// Combines the result of seven computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - ff: 6th computation.
    ///   - fg: 7th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D, E, F, G>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>,
        _ f: @escaping (A, B, C, D, E, F, G) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D, E, F, G), Failure>.zip(fa, fb, fc, fd, fe, ff, fg).map(f)
    }
    
    /// Combines the result of eight computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - ff: 6th computation.
    ///   - fg: 7th computation.
    ///   - fh: 8th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D, E, F, G, H>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>,
        _ fh: Result<H, Failure>,
        _ f: @escaping (A, B, C, D, E, F, G, H) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D, E, F, G, H), Failure>.zip(fa, fb, fc, fd, fe, ff, fg, fh).map(f)
    }
    
    /// Combines the result of nine computations in this context, using the provided function.
    ///
    /// - Parameters:
    ///   - fa: 1st computation.
    ///   - fb: 2nd computation.
    ///   - fc: 3rd computation.
    ///   - fd: 4th computation.
    ///   - fe: 5th computation.
    ///   - ff: 6th computation.
    ///   - fg: 7th computation.
    ///   - fh: 8th computation.
    ///   - fi: 9th computation.
    ///   - f: Combination function.
    /// - Returns: Result of combining the provided computations, in this context.
    static func map<A, B, C, D, E, F, G, H, I>(
        _ fa: Result<A, Failure>,
        _ fb: Result<B, Failure>,
        _ fc: Result<C, Failure>,
        _ fd: Result<D, Failure>,
        _ fe: Result<E, Failure>,
        _ ff: Result<F, Failure>,
        _ fg: Result<G, Failure>,
        _ fh: Result<H, Failure>,
        _ fi: Result<I, Failure>,
        _ f: @escaping (A, B, C, D, E, F, G, H, I) -> Success
    ) -> Result<Success, Failure> {
        Result<(A, B, C, D, E, F, G, H, I), Failure>.zip(fa, fb, fc, fd, fe, ff, fg, fh, fi).map(f)
    }
    
    /// Sequential application.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    /// - Returns: A value in this context, resulting from the transformation of the contained original value with the contained function.
    func ap<A, B>(_ fa: Result<A, Failure>) -> Result<B, Failure> where Success == (A) -> B {
        self.flatMap { f in
            fa.map { a in f(a) }
        }
    }
    
    /// Sequentially compose two computations, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fb: 2nd computation.
    /// - Returns: Result of running the second computation after the first one.
    func zipRight<B>(_ fb: Result<B, Failure>) -> Result<B, Failure> {
        .map(self, fb) { _, b in b }
    }
    
    /// Sequentially compose two computations, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fb: 2nd computation.
    /// - Returns: Result produced from the first computation after both are computed.
    func zipLeft<B>(_ fb: Result<B, Failure>) -> Result<Success, Failure> {
        .map(self, fb) { wrapped, _ in wrapped }
    }
}

// MARK: Monad methods for Result

public extension Result {
    /// Flattens this nested structure into a single layer.
    ///
    /// - Returns: Value with a single context structure.
    func flatten<A>() -> Result<A, Failure> where Success == Result<A, Failure> {
        self.flatMap(id)
    }
    
    /// Sequentially compose two computations, discarding the value produced by the first.
    ///
    /// - Parameters:
    ///   - fa: 2nd computation.
    /// - Returns: Result of running the second computation after the first one.
    func followedBy<A>(_ fa: Result<A, Failure>) -> Result<A, Failure> {
        self.flatMap(constant(fa))
    }
    
    /// Sequentially compose two computations, discarding the value produced by the second.
    ///
    /// - Parameters:
    ///   - fa: 2nd computation.
    /// - Returns: Result produced from the first computation after both are computed.
    func forEffect<A>(_ fa: Result<A, Failure>) -> Result<Success, Failure> {
        self.flatMap { wrapped in fa.as(wrapped) }
    }
    
    /// Pair the result of a computation with the result of applying a function to such result.
    ///
    /// - Parameters:
    ///   - f: A function to be applied to the result of the computation.
    /// - Returns: A tuple of the result of the computation paired with the result of the function, in this context.
    func mproduct<A>(_ f: @escaping (Success) -> Result<A, Failure>) -> Result<(Success, A), Failure> {
        self.flatMap { wrapped in
            f(wrapped).tupleLeft(wrapped)
        }
    }
    
    /// Conditionally apply a closure based on the boolean result of this computation.
    ///
    /// - Parameters:
    ///   - then: Closure to be applied if the computation evaluates to `true`.
    ///   - else: Closure to be applied if the computation evaluates to `false`.
    /// - Returns: Result of applying the corresponding closure based on the result of the computation.
    func `if`<A>(
        then f: @escaping () -> Result<A, Failure>,
        else g: @escaping () -> Result<A, Failure>
    ) -> Result<A, Failure> where Success == Bool {
        self.flatMap { boolean in
            boolean ? f() : g()
        }
    }
    
    /// Applies a monadic function and discard the result while keeping the effect.
    ///
    /// - Parameters:
    ///   - f: A monadic function which result will be discarded.
    /// - Returns: A computation with the result of the initial computation and the effect caused by the function application.
    func flatTap<A>(_ f: @escaping (Success) -> Result<A, Failure>) -> Result<Success, Failure> {
        self.flatMap { wrapped in f(wrapped).as(wrapped) }
    }
}

// MARK: ApplicativeError methods for Result

public extension Result {
    /// Lifts an error to this context.
    ///
    /// - Parameter error: A value of the error type.
    /// - Returns: A value representing the error in this context.
    static func raiseError(_ error: Failure) -> Result<Success, Failure> {
        .failure(error)
    }
    
    /// Creates a value of this type from an Either.
    ///
    /// - Parameter either: Either value to convert to this type.
    /// - Returns: A value that represents the same content from Either, in this context.
    static func from(either: Either<Failure, Success>) -> Result<Success, Failure> {
        either.fold(Result.failure, Result.success)
    }
    
    /// Handles an error, potentially recovering from it by mapping it to a value in this context.
    ///
    /// - Parameters:
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    func handleErrorWith(_ f: @escaping (Failure) -> Result<Success, Failure>) -> Result<Success, Failure> {
        self.fold(f, Result.success)
    }
    
    /// Handles an error, potentially recovering from it by mapping it to a value.
    ///
    /// - Parameters:
    ///   - f: A recovery function.
    /// - Returns: A value where the possible errors have been recovered using the provided function.
    func handleError(_ f: @escaping (Failure) -> Success) -> Result<Success, Failure> {
        handleErrorWith(f >>> Result.success)
    }
}

