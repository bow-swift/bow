import XCTest
@testable import BowLaws
@testable import Bow

class ObservableKTest : XCTestCase {
    
    class ObservableKEq<T> : Eq where T : Equatable {
        typealias A = ObservableKOf<T>
        
        func eqv(_ a: Kind<ForObservableK, T>, _ b: Kind<ForObservableK, T>) -> Bool {
            return a.fix().value.blockingGet() == b.fix().value.blockingGet()
        }
    }
    
    class ObservableKEqUnit : Eq {
        typealias A = ObservableKOf<Bow.Unit>
        
        func eqv(_ a: ObservableKOf<Bow.Unit>, _ b: ObservableKOf<Bow.Unit>) -> Bool {
            let x : Bow.Unit? = a.fix().value.blockingGet()
            let y : Bow.Unit? = b.fix().value.blockingGet()
            
            return !xor(x == nil, y == nil)
        }
    }
    
    class ObservableKEqEither : Eq {
        typealias A = ObservableKOf<EitherOf<CategoryError, Int>>
        
        func eqv(_ a: ObservableKOf<EitherOf<CategoryError, Int>>, _ b: ObservableKOf<EitherOf<CategoryError, Int>>) -> Bool {
            let x = Option.fromOption(a.fix().value.blockingGet())
            let y = Option.fromOption(b.fix().value.blockingGet())
            return Option.eq(Either.eq(CategoryError.eq, Int.order)).eqv(x, y)
        }
    }
    
    let eq = ObservableKEq<Int>()
    let generator = { (x : Int) -> ObservableKOf<Int> in ObservableK.pure(x) }
    
    func testFunctorLaws() {
        FunctorLaws.check(functor: ObservableK<Int>.functor(), generator: generator, eq: eq, eqUnit: ObservableKEqUnit())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws.check(applicative: ObservableK<Int>.applicative(), eq: eq)
    }
    
    func testMonadLaws() {
        MonadLaws.check(monad: ObservableK<Int>.monad(), eq: eq)
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws.check(monadError: ObservableK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws.check(applicativeError: ObservableK<Int>.applicativeError(), eq: eq, eqEither: ObservableKEqEither(), gen: constant(CategoryError.unknown))
    }
    
    func testFoldableLaws() {
        FoldableLaws.check(foldable: ObservableK<Int>.foldable(), generator: generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws.check(traverse: ObservableK<Int>.traverse(), functor: ObservableK<Int>.functor(), generator: generator, eq: eq)
    }
    
    func testAsyncLaws() {
        AsyncLaws<ForObservableK, CategoryError>.check(async: ObservableK<Int>.effect(), monadError: ObservableK<Int>.monadError(), eq: eq, gen: constant(CategoryError.unknown))
    }
}
