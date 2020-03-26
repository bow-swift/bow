import SwiftCheck
import Bow
import BowGenerators

public class ComonadTracedLaws<F: ComonadTraced & EquatableK & ArbitraryK, M: Equatable & Arbitrary & Monoid> where F.M == M {
    
    public static func check() {
        traceEmpty()
        sequentialTracing()
    }
    
    static func traceEmpty() {
        property("trace empty is equal to extract") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.trace(.empty())
                ==
            fa.value.extract()
        }
    }
    
    static func sequentialTracing() {
        property("tracing twice is equal to tracing combination of values") <~ forAll { (fa: KindOf<F, Int>, s: M, t: M) in
            
            fa.value.coflatMap { wa in wa.trace(t) }.trace(s)
                ==
            fa.value.trace(s.combine(t))
        }
    }
}
