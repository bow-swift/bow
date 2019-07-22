import Foundation
import SwiftCheck
import Bow
import BowEffects
import BowLaws

public class AsyncLaws<F: Async & EquatableK> where F.E: Arbitrary {
    public static func check() {
        success()
        error()
    }
    
    private static func success() {
        property("Success equivalence") <~ forAll { (a: Int) in
            return F.runAsync({ ff in ff(Either<F.E, Int>.right(a)) }) == F.pure(a)
        }
    }
    
    private static func error() {
        property("Error equivalence") <~ forAll { (error: F.E) in
            return F.runAsync({ ff in ff(Either<F.E, Int>.left(error)) }) ==
                F.raiseError(error)
        }
    }
}
