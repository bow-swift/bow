import SwiftCheck
import Bow
import BowGenerators

public class HashableKLaws<F: HashableK & ArbitraryK, A: Arbitrary & Hashable> {
    
    public static func check() {
        coherenceWithEquality()
    }
    
    private static func coherenceWithEquality() {
        let generator: Gen<(KindOf<F, A>, KindOf<F, A>)> = {
          let equal = KindOf<F, A>.arbitrary.map { fa in (fa, fa) }
          let distinct = Gen.zip(KindOf<F, A>.arbitrary, KindOf<F, A>.arbitrary)
          return Gen.one(of: [equal, distinct])
        }()

        property("Equal objects have equal hash") <~ forAllNoShrink(generator) { (tuple: (KindOf<F, A>, KindOf<F, A>)) in
            let fa1 = tuple.0
            let fa2 = tuple.1
            return (fa1.value == fa2.value) ==> {
                var hasher1 = Hasher()
                var hasher2 = Hasher()
                fa1.value.hash(into: &hasher1)
                fa2.value.hash(into: &hasher2)
                return hasher1.finalize() == hasher2.finalize()
            }
        }
    }
}
