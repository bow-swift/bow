import SwiftCheck
@testable import Bow

class TraverseLaws<F: Traverse & EquatableK> {
    static func check(generator: @escaping (Int) -> Kind<F, Int>) {
        identityTraverse(generator)
    }
    
    private static func identityTraverse(_ generator: @escaping (Int) -> Kind<F, Int>) {
        property("Identity traverse") <- forAll { (x: Int, y: Int) in
            let f: (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            let fa = generator(x)
            return Id.fix(F.traverse(fa, f)).value == F.map(F.map(fa, f), { a in Id.fix(a).value })
        }
    }
}
