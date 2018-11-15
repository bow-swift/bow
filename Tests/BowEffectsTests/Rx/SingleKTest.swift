import XCTest
@testable import BowLaws
@testable import Bow
@testable import BowEffects

class SingleKTest : XCTestCase {
    class SingleKEq<T> : Eq where T : Equatable {
        typealias A = SingleKOf<T>
        
        func eqv(_ a: SingleKOf<T>, _ b: SingleKOf<T>) -> Bool {
            return a.fix().value.blockingGet() == b.fix().value.blockingGet()
        }
    }
    
    class SingleKUnitEq : Eq {
        typealias A = SingleKOf<Bow.Unit>
        
        func eqv(_ a: SingleKOf<Bow.Unit>, _ b: SingleKOf<Bow.Unit>) -> Bool {
            let x : Bow.Unit? = a.fix().value.blockingGet()
            let y : Bow.Unit? = b.fix().value.blockingGet()
            
            return (x == nil && y == nil) || (x != nil && y != nil)
        }
    }
    
    class SingleKEitherEq : Eq {
        typealias A = Kind<ForSingleK, EitherOf<CategoryError, Int>>
        
        func eqv(_ a: Kind<ForSingleK, EitherOf<CategoryError, Int>>, _ b: Kind<ForSingleK, EitherOf<CategoryError, Int>>) -> Bool {
            let x = Option.fromOption(a.fix().value.blockingGet())
            let y = Option.fromOption(b.fix().value.blockingGet())
            return Option.eq(Either.eq(CategoryError.eq, Int.order)).eqv(x, y)
        }
    }
    
    let generator = { (x : Int) -> SingleKOf<Int> in SingleK.pure(x) }
    let eq = SingleKEq<Int>()
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: SingleK<Int>.functor(), generator: generator, eq: eq, eqUnit: SingleKUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws.check(applicative: SingleK<Int>.applicative(), eq: eq)
    }
    
    func testMonadLaws() {
        MonadLaws.check(monad: SingleK<Int>.monad(), eq: eq)
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws.check(monadError: SingleK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ForSingleK, CategoryError>.check(
            applicativeError: SingleK<Int>.applicativeError(),
            eq: eq,
            eqEither: SingleKEitherEq(),
            gen: constant(CategoryError.unknown))
    }
    
    func testAsyncLaws() {
        AsyncLaws<ForSingleK, CategoryError>.check(async: SingleK<Int>.effect(), monadError: SingleK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
}
