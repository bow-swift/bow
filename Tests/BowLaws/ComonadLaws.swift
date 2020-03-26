import SwiftCheck
import Bow
import BowGenerators

public class ComonadLaws<F: Comonad & EquatableK & ArbitraryK> {
    public static func check() {
        duplicateThenExtractIsId()
        duplicateThenMapExtractIsId()
        mapAndCoflatMapCoherence()
        leftIdentity()
        rightIdentity()
        cokleisliLeftIdentity()
        cokleisliRightIdentity()
    }
    
    private static func duplicateThenExtractIsId() {
        property("Duplicate then extract is equivalent to id") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.duplicate().extract()
                ==
            fa.value
        }
    }
    
    private static func duplicateThenMapExtractIsId() {
        property("Duplicate then map extract is equivalent to id") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.duplicate().map(F.extract)
                ==
            fa.value
        }
    }
    
    private static func mapAndCoflatMapCoherence() {
        property("map and coflatMap coherence") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            
            fa.value.map(f.getArrow)
                ==
            fa.value.coflatMap { a in f.getArrow(a.extract()) }
        }
    }
    
    private static func leftIdentity() {
        property("Left identity") <~ forAll { (fa: KindOf<F, Int>) in
            
            fa.value.coflatMap(F.extract)
                ==
            fa.value
        }
    }
    
    private static func rightIdentity() {
        property("Right identity") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Int>) in
            let f = { (_ : Kind<F, Int>) in fb.value }
            
            return fa.value.coflatMap(f).extract()
                ==
            f(fa.value)
        }
    }
    
    private static func cokleisliLeftIdentity() {
        property("Cokleisli left identity") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Int>) in
            let f = { (_: Kind<F, Int>) in fb.value }
            
            return Cokleisli(F.extract).andThen(Cokleisli(f)).run(fa.value)
                ==
            f(fa.value)
        }
    }
    
    private static func cokleisliRightIdentity() {
        property("Cokleisli right identity") <~ forAll { (fa: KindOf<F, Int>, fb: KindOf<F, Int>) in
            let f = { (_: Kind<F, Int>) in fb.value }
            
            return Cokleisli(f).andThen(Cokleisli(F.extract)).run(fa.value)
                ==
            f(fa.value)
        }
    }
}
