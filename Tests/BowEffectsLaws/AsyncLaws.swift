import Foundation
import SwiftCheck
import Bow
@testable import BowEffects

public class AsyncLaws<F: Async & EquatableK> where F.E: Arbitrary {
    
    public static func check() {
        success()
        error()
        continueOnJumpsQueues()
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

    private static func nonEmpty() -> Gen<String> { return String.arbitrary.suchThat { str in str.count > 5 } }
    private static func continueOnJumpsQueues() {
        property("continueOnJumpsThreads") <- forAll(nonEmpty(), nonEmpty()) { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)
            
//            print("QUEUES: \(id1), \(id2)")
//
//            let x = F.pure(())
//                .continueOn(queue1)
//                .map { _ -> String in
//                    let label = QueueLabel().get
//                    print("QUEUE1: " + label)
//                    return label
//                }
//                .continueOn(queue2)
//                .map { (x: String) -> String in
//                    let label = QueueLabel().get
//                    print("QUEUE2: " + label)
//                    return x + label }
//
//            return x == F.pure(id1 + id2)
            return F.pure(())
                .continueOn(queue1)
                .map { _ in QueueLabel().get }
                .continueOn(queue2)
                .map { x in x + QueueLabel().get } == F.pure(id1 + id2)
        }
    }

    private static func asyncConstructor() {
        property("asyncConstructor") <- forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)

            return F.later(queue1) { currentQueueLabel() }
                .flatMap { x in F.later(queue2) { x + currentQueueLabel() } }
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
                { _ in F.pure(self.currentQueueLabel()) },
                { _, b in F.pure(b).continueOn(queue2) },
                { _, _, c in F.pure(c + currentQueueLabel()) }
            ) == F.pure(id1 + id2)
        }
    }

    private static func asyncCanBeDerivedFromAsyncF() {
        property("asyncCanBeDerivedFromAsyncF") <- forAll { (x: Int) in
            let either = Either<F.E, Int>.right(x)
            let k: Proc<F.E, Int> = { f in f(either) }

            return F.async(k) == F.asyncF { cb in F.delay { k(cb) } }
        }
    }

    private static func currentQueueLabel() -> String {
        return DispatchQueue.currentLabel
    }
}

struct QueueLabel {
    var get: String {
        return DispatchQueue.currentLabel
    }
}
