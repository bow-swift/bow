import XCTest
import BrightFutures
@testable import BowLaws
@testable import Bow
@testable import BowBrightFutures
@testable import BowResult
@testable import BowEffectsLaws

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

extension FutureKPartial: EquatableK where E: Equatable {
    public static func eq<A: Equatable>(_ lhs: Kind<FutureKPartial<E>, A>, _ rhs: Kind<FutureKPartial<E>, A>) -> Bool {
        let fa = FutureK.fix(lhs).value.blockingGet()
        let fb = FutureK.fix(rhs).value.blockingGet()

        return fa == fb
    }
}

class FutureKTest: XCTestCase {
    let generator = { (x : Int) -> FutureKOf<CategoryError, Int> in
        (x % 2 == 0) ?
            FutureK.pure(x) :
            FutureK.raiseError(CategoryError.arbitrary.generate)
    }

    func testFunctorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            FunctorLaws<FutureKPartial<CategoryError>>.check(generator: self.generator)
        }
    }
    
    func testApplicativeLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            ApplicativeLaws<FutureKPartial<CategoryError>>.check()
        }
    }

    func testSelectiveLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            SelectiveLaws<FutureKPartial<CategoryError>>.check()
        }
    }
    
    func testMonadLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            MonadLaws<FutureKPartial<CategoryError>>.check()
        }
    }
    
    func testApplicativeErrorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            ApplicativeErrorLaws<FutureKPartial<CategoryError>>.check()
        }
    }
    
    func testMonadErrorLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            MonadErrorLaws<FutureKPartial<CategoryError>>.check()
        }
    }
    
    func testAsyncLaws() {
        DispatchQueue.global(qos: .userInteractive).async {
            //AsyncLaws<FutureKPartial<CategoryError>>.check()
        }
    }
}
