import XCTest
@testable import Bow

class MaybeKTest : XCTestCase {
    
    class MaybeKEq<T> : Eq where T : Equatable {
        typealias A = MaybeKOf<T>
        
        func eqv(_ a: Kind<ForMaybeK, T>, _ b: Kind<ForMaybeK, T>) -> Bool {
            return a.fix().value.blockingGet() == b.fix().value.blockingGet()
        }
    }
    
    class MaybeKEqUnit : Eq {
        typealias A = MaybeKOf<Bow.Unit>
        
        func eqv(_ a: MaybeKOf<Bow.Unit>, _ b: MaybeKOf<Bow.Unit>) -> Bool {
            let x : Bow.Unit? = a.fix().value.blockingGet()
            let y : Bow.Unit? = b.fix().value.blockingGet()
            
            return (x == nil && y == nil) || (x != nil && y != nil)
        }
    }
    
    class MaybeKEitherEq : Eq {
        typealias A = Kind<ForMaybeK, EitherOf<CategoryError, Int>>
        
        func eqv(_ a: Kind<ForMaybeK, EitherOf<CategoryError, Int>>, _ b: Kind<ForMaybeK, EitherOf<CategoryError, Int>>) -> Bool {
            let x = Option.fromOption(a.fix().value.blockingGet())
            let y = Option.fromOption(b.fix().value.blockingGet())
            
            return Option.eq(Either.eq(CategoryError.eq, Int.order)).eqv(x, y)
        }
    }
    
    let eq = MaybeKEq<Int>()
    let generator = { (x : Int) -> MaybeKOf<Int> in MaybeK.pure(x) }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: MaybeK<Int>.functor(), generator: generator, eq: eq, eqUnit: MaybeKEqUnit())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws.check(applicative: MaybeK<Int>.applicative(), eq: eq)
    }
    
    func testMonadLaws() {
        MonadLaws.check(monad: MaybeK<Int>.monad(), eq: eq)
    }
    
    func testFoldableLaws() {
        FoldableLaws.check(foldable: MaybeK<Int>.foldable(), generator: generator)
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws.check(monadError: MaybeK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws.check(applicativeError: MaybeK<Int>.applicativeError(), eq: eq, eqEither: MaybeKEitherEq(), gen: constant(CategoryError.unknown))
    }
    
    func testAsyncLaws() {
        AsyncLaws<ForMaybeK, CategoryError>.check(async: MaybeK<Int>.effect(), monadError: MaybeK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
}
