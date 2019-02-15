import Foundation
import SwiftCheck
@testable import Bow

class MonadStateLaws<F: MonadState & EquatableK> where F.S == Int {
    
    static func check() {
        getIdempotent()
        setTwice()
        setGet()
        getSet()
    }
    
    private static func getIdempotent() {
        property("Idempotence") <- forAll { (_: Int) in
            return F.flatMap(F.get(), { _ in F.get() }) == F.get()
        }
    }
    
    private static func setTwice() {
        property("Set twice is equivalent to set only the second") <- forAll { (s: Int, t: Int) in
            return isEqual(F.flatMap(F.set(s), { _ in F.set(t) }), F.set(t))
        }
    }
    
    private static func setGet() {
        property("Get after set retrieves the original value") <- forAll { (s: Int) in
            return F.flatMap(F.set(s), { _ in F.get() }) == F.flatMap(F.set(s), { _ in F.pure(s) })
        }
    }
    
    private static func getSet() {
        property("Get set") <- forAll { (_: Int) in
            return isEqual(F.flatMap(F.get(), F.set), F.pure(()))
        }
    }
}
