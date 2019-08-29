import SwiftCheck
import Bow
import BowGenerators

public class ApplicativeErrorLaws<F: ApplicativeError & EquatableK> where F.E: Equatable, F.E: Arbitrary {
    public static func check()  {
        handle()
        handleWith()
        handleWithPure()
        attemptError()
        attemptSuccess()
        attemptFromEitherConsistentWithPure()
        catchesError()
        catchesSuccess()
    }
    
    private static func handle() {
        property("Applicative error handle") <~ forAll { (a: Int, error: F.E) in
            let f = { (_: F.E) in a }
            return F.handleError(F.raiseError(error), f) == F.pure(f(error))
        }
    }
    
    private static func handleWith() {
        property("Applicative error handle with") <~ forAll { (a: Int, error: F.E) in
            let f = { (_: F.E) in F.pure(a) }
            return F.handleErrorWith(F.raiseError(error), f) == f(error)
        }
    }
    
    private static func handleWithPure() {
        property("Applicative error handle with pure") <~ forAll { (a: Int) in
            let f = { (_: F.E) in F.pure(a) }
            return F.handleErrorWith(F.pure(a), f) == F.pure(a)
        }
    }
    
    private static func attemptError() {
        property("Attempt error") <~ forAll { (_: Int, error: F.E) in
            return F.attempt(F.raiseError(error)) == F.pure(Either<F.E, Int>.left(error))
        }
    }
    
    private static func attemptSuccess() {
        property("Attempt success") <~ forAll { (a: Int) in
            return F.attempt(F.pure(a)) == F.pure(Either<F.E, Int>.right(a))
        }
    }
    
    private static func attemptFromEitherConsistentWithPure() {
        property("Attempt from either consistent with pure") <~ forAll { (either: Either<F.E, Int>) in
            return F.attempt(F.fromEither(either)) == F.pure(either)
        }
    }
    
    private static func catchesError() {
        property("Catch") <~ forAll { (_: Int, error: F.E) in
            if error is Error {
                let f : () throws -> Int = { throw error as! Error }
                return F.catchError(f, { e in e as! F.E }) == F.raiseError(error)
            } else {
                return true
            }
        }
    }
    
    private static func catchesSuccess() {
        property("Catch") <~ forAll { (a: Int) in
            let f : () throws -> Int = { return a }
            return F.catchError(f, { e in e as! F.E }) == F.pure(a)
        }
    }
}

enum CategoryError: Error {
    case common
    case fatal
    case unknown
}

extension CategoryError: Semigroup {
    func combine(_ other: CategoryError) -> CategoryError {
        switch (self, other) {
        case (.fatal, _), (_, .fatal): return .fatal
        case (.common, _), (_, .common): return .common
        default: return .unknown
        }
    }
}

extension CategoryError: Equatable {}

extension CategoryError: Arbitrary {
    static var arbitrary: Gen<CategoryError> {
        return Gen<CategoryError>.fromElements(of: [CategoryError.common, CategoryError.fatal, CategoryError.unknown])
    }
}
