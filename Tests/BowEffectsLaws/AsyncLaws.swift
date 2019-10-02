import Foundation
import SwiftCheck
import Bow
import BowLaws
import BowEffects

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
        property("Success equivalence") <~ forAll { (a: Int) in
            return F.async({ ff in ff(Either<F.E, Int>.right(a)) }) == F.pure(a)
        }
    }
    
    private static func error() {
        property("Error equivalence") <~ forAll { (error: F.E) in
            return F.async({ ff in ff(Either<F.E, Int>.left(error)) }) ==
                F.raiseError(error)
        }
    }

    private static func nonEmpty() -> Gen<String> { return String.arbitrary.suchThat { str in str.count > 5 } }
    private static func continueOnJumpsQueues() {
        property("continueOnJumpsThreads") <~ forAll(nonEmpty(), nonEmpty()) { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)
            
            return F.pure(())
                .continueOn(queue1)
                .map { _ in QueueLabel().get }
                .continueOn(queue2)
                .map { x in x + QueueLabel().get } == F.pure(id1 + id2)
        }
    }

    private static func asyncConstructor() {
        property("asyncConstructor") <~ forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)

            return F.later(queue1) { currentQueueLabel() }
                .flatMap { x in F.later(queue2) { x + currentQueueLabel() } }
                == F.pure(id1 + id2)
        }
    }

    private static func continueOnComprehension() {
        property("continueOnComprehension") <~ forAll { (id1: String, id2: String) in
            let queue1 = DispatchQueue(label: id1)
            let queue2 = DispatchQueue(label: id2)
            let l1 = F.var(String.self)
            let l2 = F.var(String.self)
            
            return binding(
                continueOn(queue1),
                l1 <-- F.pure(currentQueueLabel()),
                continueOn(queue2),
                l2 <-- F.pure(currentQueueLabel()),
                yield: l1.get + l2.get) == F.pure(id1 + id2)
        }
    }

    private static func asyncCanBeDerivedFromAsyncF() {
        property("asyncCanBeDerivedFromAsyncF") <~ forAll { (x: Int) in
            let either = Either<F.E, Int>.right(x)
            let k: Proc<F.E, Int> = { f in f(either) }

            return F.async(k) == F.asyncF { cb in F.later { k(cb) } }
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
