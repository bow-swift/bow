import SwiftCheck
import Bow
import BowGenerators

class TraverseLaws<F: Traverse & EquatableK & ArbitraryK> {
    static func check() {
        identityTraverse()
    }
    
    private static func identityTraverse() {
        property("Identity traverse") <- forAll { (fa: KindOf<F, Int>, y: Int) in
            let f: (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            return Id.fix(F.traverse(fa.value, f)).value == F.map(F.map(fa.value, f), { a in Id.fix(a).value })
        }
    }
}
