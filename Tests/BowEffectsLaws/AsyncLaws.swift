import Foundation
import SwiftCheck
import Bow
import BowEffects

public class AsyncLaws<F: Async & EquatableK> where F.E: Arbitrary {
    
    public static func check() {
        success()
        error()
        continueOnJumpsThreads()
        asyncConstructor()
        continueOnComprehension()
        asyncCanBeDerivedFromAsyncF()
    }
    
    private static func success() {
        property("Success equivalence") <- forAll { (a: Int) in
            return F.async({ ff in ff(Either<F.E, Int>.right(a)) }) == F.pure(a)
        }
    }
    
    private static func error() {
        property("Error equivalence") <- forAll { (error: F.E) in
            return F.async({ ff in ff(Either<F.E, Int>.left(error)) }) ==
                F.raiseError(error)
        }
    }

    private static func continueOnJumpsThreads() {
        property("continueOnJumpsThreads") <- forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)

            return F.pure(())
                .continueOn(queue1)
                .map { _ in currentQueueLabel }
                .continueOn(queue2)
                .map { x in x + currentQueueLabel } == F.pure(id1 + id2)
        }
    }

    private static func asyncConstructor() {
        property("asyncConstructor") <- forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)

            return F.delay(queue1) { currentQueueLabel }
                .flatMap { x in F.delay(queue2) { x + currentQueueLabel } }
                == F.pure(id1 + id2)
        }
    }

    private static func continueOnComprehension() {
        property("continueOnComprehension") <- forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)
            let fa = F.pure(())
            return F.binding(
                { fa.continueOn(queue1) },
                { _ in F.pure(currentQueueLabel) },
                { _, b in F.pure(b).continueOn(queue2) },
                { _, _, c in F.pure(c + currentQueueLabel) }
            ) == F.pure(id1 + id2)
        }
    }

    private static func asyncCanBeDerivedFromAsyncF() {
        property("asyncCanBeDerivedFromAsyncF") <- forAll { (x: Int) in
            let either = Either<F.E, Int>.right(x)
            let k: Proc<F.E, Int> = { f in f(either) }

            return F.async(k) == F.asyncF { cb in F.delay { try k(cb) } }
        }
    }

    private static var currentQueueLabel: String {
        return OperationQueue.current?.underlyingQueue?.label ?? ""
    }
}
