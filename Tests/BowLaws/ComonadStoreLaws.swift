import SwiftCheck
import Bow
import BowGenerators

public class ComonadStoreLaws<F: ComonadStore & EquatableK & ArbitraryK> where F.S == Int {

    public static func check() {
        positionCoflatMap()
        peekPosition()
    }
    
    static func positionCoflatMap() {
        property("coflatMap does not change position") <~ forAll { (fa: KindOf<F, Int>, f: ArrowOf<Int, Int>) in
            let ff: (Kind<F, Int>) -> Int = { wa in f.getArrow(wa.extract()) }
            
            return fa.value.coflatMap(ff).position ==
                fa.value.position
        }
    }
    
    static func peekPosition() {
        property("peek at position is equal to extract") <~ forAll { (fa: KindOf<F, Int>) in
            fa.value.peek(fa.value.position) == fa.value.extract()
        }
    }
}
