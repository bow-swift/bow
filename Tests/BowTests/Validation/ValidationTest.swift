import XCTest
import Nimble
@testable import Bow

class ValidationTest : XCTestCase {
    struct Example : Equatable {
        let number : Int
        let text : String
    }
    
    enum ExampleError : Error {
        case wrongNumber
        case wrongText
    }
    
    func testSuccessfulValidation() {
        let result = validate(Either<ExampleError, Int>.right(1),
                              Either<ExampleError, String>.right("Whatever"),
                              Example.init).get()
        expect(result).to(equal(Example(number: 1, text: "Whatever")))
    }
    
    func testUnsuccessfulValidation() {
        let result = validate(Either<ExampleError, Int>.left(.wrongNumber),
                              Either<ExampleError, String>.right("Whatever"),
                              Example.init).swap().get()
        expect(result).to(equal([.wrongNumber]))
        
        let result2 = validate(Either<ExampleError, Int>.left(.wrongNumber),
                              Either<ExampleError, String>.left(.wrongText),
                              Example.init).swap().get()
        expect(result2).to(equal([.wrongNumber, .wrongText]))
    }
}
