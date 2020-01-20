import SwiftCheck
import Bow
import BowGenerators

public class ComonadEnvLaws<F: ComonadEnv & EquatableK & ArbitraryK> where F.E == Int {
    public static func check() {
        askLocal()
        extractLocal()
        coflatMapLocal()
    }
    
    static func askLocal() {
        property("Ask followed by local is equivalent to applying a function to ask") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            fa.value.local(f.getArrow).ask() ==
                f.getArrow(fa.value.ask())
        }
    }
    
    static func extractLocal() {
        property("Local does not affect extract") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            fa.value.local(f.getArrow).extract() ==
                fa.value.extract()
        }
    }
    
    static func coflatMapLocal() {
        property("CoflatMap Local") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>, g: ArrowOf<Int, Int>) in
            let h: (Kind<F, Int>) -> Int = { wa in g.getArrow(wa.extract()) }

            return fa.value.local(f.getArrow).coflatMap(h) ==
                fa.value.coflatMap(h).local(f.getArrow)
        }
    }
}
