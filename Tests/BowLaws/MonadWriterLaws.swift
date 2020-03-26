import SwiftCheck
import Bow

public class MonadWriterLaws<F: MonadWriter & EquatableK> where F.W == Int {
    public static func check() {
        writerPure()
        tellFusion()
        listenPure()
        listenWriterProperty()
        censorTell()
    }
    
    private static func writerPure() {
        property("Writer pure") <~ forAll { (a: Int) in
            
            F.writer((.empty(), a))
                ==
            F.pure(a)
        }
    }
    
    private static func tellFusion() {
        property("Tell fusion") <~ forAll { (a: Int, b: Int) in
            
            isEqual(
                F.tell(a).flatMap { _ in F.tell(b) },
                F.tell(a.combine(b)))
        }
    }
    
    private static func listenPure() {
        property("Listen pure") <~ forAll { (a: Int) in
            
            isEqual(
                F.pure(a).listen(),
                F.pure((.empty(), a)))
        }
    }
    
    private static func listenWriterProperty() {
        property("Listen writer") <~ forAll { (a: Int, w: Int) in
            let tuple = (w, a)
            
            return isEqual(
                F.writer(tuple).listen(),
                F.tell(tuple.0).map { _ in tuple })
        }
    }
    
    private static func censorTell() {
        property("Censor tell") <~ forAll { (a: Int, w: Int, f: ArrowOf<Int, Int>) in
            
            isEqual(
                F.writer((f.getArrow(w), a)).listen(),
                F.writer((w, a)).censor(f.getArrow).listen())
        }
    }
    
}
