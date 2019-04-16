import XCTest
import SwiftCheck
@testable import Bow
@testable import BowResult

enum ResultError: Int, Error {
    case warning
    case fatal
    case unknown
}

class ResultTest: XCTestCase {
    func generateEither(_ x: Int) -> Either<ResultError, Int> {
        return x % 2 == 0 ? Either.left(.warning): Either.right(x)
    }
    
    func generateValidated(_ x: Int) -> Validated<ResultError, Int> {
        return x % 2 == 0 ? Validated.invalid(.fatal) : Validated.valid(x)
    }
    
    func testResultEitherIsomorphism() {
        property("Either and Result are isomorphic") <- forAll { (x: Int) in
            return self.generateEither(x).toResult().toEither() == self.generateEither(x)
        }
    }
    
    func testResultValidateIsomorphism() {
        property("Validated and Result are isomorphic") <- forAll { (x: Int) in
            return self.generateValidated(x).toResult().toValidated() == self.generateValidated(x)
        }
    }
}
