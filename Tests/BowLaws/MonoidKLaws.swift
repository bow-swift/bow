import Foundation
import SwiftCheck
@testable import Bow

class MonoidKLaws<F: MonoidK & EquatableK> {
    
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        leftIdentity(generator)
        rightIdentity(generator)
    }
    
    private static func leftIdentity(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("MonoidK left identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return F.emptyK().combineK(fa) == fa
        }
    }
    
    private static func rightIdentity(_ generator : @escaping (Int) -> Kind<F, Int>) {
        property("MonoidK left identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return fa.combineK(F.emptyK()) == fa
        }
    }
}
