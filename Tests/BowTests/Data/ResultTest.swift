import XCTest
import SwiftCheck
import Bow

enum ResultError: Int, Error {
    case warning
    case fatal
    case unknown
}

extension ResultError: Arbitrary {
    static var arbitrary: Gen<ResultError> {
        return Gen.fromElements(of: [.warning, .fatal, .unknown])
    }
}

class ResultTest: XCTestCase {
    func testResultEitherIsomorphism() {
        property("Either and Result are isomorphic") <- forAll { (x: Either<ResultError, Int>) in
            return x.toResult().toEither() == x
        }
    }
    
    func testResultValidateIsomorphism() {
        property("Validated and Result are isomorphic") <- forAll { (x: Validated<ResultError, Int>) in
            return x.toResult().toValidated() == x
        }
    }
}
