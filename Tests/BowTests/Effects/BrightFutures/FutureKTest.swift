import XCTest
import BrightFutures
@testable import Bow

private let forcedFutureQueue = DispatchQueue(label: "forcedFutureQueue", attributes: .concurrent)

extension Future {
    private func forcedFuture(createFuture: @escaping () -> Future<T, E>) -> Either<E, T> {
        var result : Future<T, E>?
        let sem = DispatchSemaphore(value: 0)
        forcedFutureQueue.async {
            result = createFuture()
            sem.signal()
        }
        sem.wait()
        return result!.forced().toEither()
    }
    
    func blockingGet() -> Either<E, T> {
        return forcedFuture{ self }
    }
}

class FutureKTest : XCTestCase {
    class FutureKEq<E, T, EqE, EqT> : Eq where EqE : Eq, EqE.A == E, EqT : Eq, EqT.A == T, E : Error {
        typealias A = FutureKOf<E, T>
        
        let eqE : EqE
        let eqT : EqT
        
        init(_ eqE : EqE, _ eqT : EqT) {
            self.eqE = eqE
            self.eqT = eqT
        }
        
        func eqv(_ a: FutureKOf<E, T>, _ b: FutureKOf<E, T>) -> Bool {
            let fa = FutureK<E, T>.fix(a).value.blockingGet()
            let fb = FutureK<E, T>.fix(b).value.blockingGet()
            
            return Either.eq(eqE, eqT).eqv(fa, fb)
        }
    }
    
    let generator = { (x : Int) -> FutureKOf<CategoryError, Int> in
        (x % 2 == 0) ?
            FutureK.pure(x) :
            FutureK.raiseError(CategoryError.arbitrary.generate)
    }
    
    let eq = FutureKEq(CategoryError.eq, Int.order)
    
    func testFunctorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            FunctorLaws.check(functor: FutureK<CategoryError, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: FutureKEq(CategoryError.eq, UnitEq()))
        }
    }
    
    func testApplicativeLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            ApplicativeLaws.check(applicative: FutureK<CategoryError, Int>.applicative(), eq: self.eq)
        }
    }
    
    func testMonadLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            MonadLaws.check(monad: FutureK<CategoryError, Int>.monad(), eq: self.eq)
        }
    }
    
    func testApplicativeErrorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            ApplicativeErrorLaws.check(applicativeError: FutureK<CategoryError, Int>.applicativeError(), eq: self.eq, eqEither: FutureKEq(CategoryError.eq, Either.eq(CategoryError.eq, Int.order)), gen: { CategoryError.arbitrary.generate })
        }
    }
    
    func testMonadErrorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            MonadErrorLaws.check(monadError: FutureK<CategoryError, Int>.monadError(), eq: self.eq, gen: { CategoryError.arbitrary.generate })
        }
    }
    
    func testAsyncLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            AsyncLaws.check(async: FutureK<CategoryError, Int>.effect(), monadError: FutureK<CategoryError, Int>.monadError(), eq: self.eq, gen: { CategoryError.arbitrary.generate })
        }
    }
}
