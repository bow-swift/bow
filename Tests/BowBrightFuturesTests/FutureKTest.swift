import XCTest
import BrightFutures
@testable import BowLaws
import Bow
import BowBrightFutures
import BowBrightFuturesGenerators
@testable import BowEffectsLaws

private let forcedFutureQueue = DispatchQueue(label: "forcedFutureQueue", attributes: .concurrent)

extension Future {
    private func forcedFuture(createFuture: @escaping () -> Future<T, E>) -> Either<E, T> {
        var result: Future<T, E>?
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
    func testFunctorLaws() {
        FunctorLaws<FutureKPartial<CategoryError>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<FutureKPartial<CategoryError>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<FutureKPartial<CategoryError>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<FutureKPartial<CategoryError>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<FutureKPartial<CategoryError>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<FutureKPartial<CategoryError>>.check()
    }
    
    func testAsyncLaws() {
        AsyncLaws<FutureKPartial<CategoryError>>.check()
    }
}
