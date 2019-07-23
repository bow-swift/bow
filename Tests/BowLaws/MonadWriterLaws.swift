import SwiftCheck
import Bow

public class MonadWriterLaws<F: MonadWriter & EquatableK> where F.W == Int {
    public static func check() {
        writerPure()
        tellFusion()
        listenPure()
        listenWriterProperty()
        comprehension()
    }
    
    private static func writerPure() {
        property("Writer pure") <~ forAll { (a: Int) in
            return F.writer((Int.empty(), a)) == F.pure(a)
        }
    }
    
    private static func tellFusion() {
        property("Tell fusion") <~ forAll { (a: Int, b: Int) in
            return isEqual(F.flatMap(F.tell(a), { _ in F.tell(b) }),
                           F.tell(a.combine(b)))
        }
    }
    
    private static func listenPure() {
        property("Listen pure") <~ forAll { (a: Int) in
            return isEqual(F.listen(F.pure(a)), F.pure((Int.empty(), a)))
        }
    }
    
    private static func listenWriterProperty() {
        property("Listen writer") <~ forAll { (a: Int, w: Int) in
            let tuple = (w, a)
            return isEqual(F.listen(F.writer(tuple)), F.map(F.tell(tuple.0), { _ in tuple }))
        }
    }
    
    private static func comprehension() {
        property("Bindings") <~ forAll { (w: Int) in
            let v1 = F.var(String.self)
            let v2 = F.var(Void.self)
            
            let x = binding(
                tellWriter(w),
                |<-censorWriter { n in 2 * n },
                (v1, v2) <-- listensWriter { x in "\(x)" },
                yield: v1.get + "\(v2.get)")
            
            let y = F.tell(w)
                .censor { n in 2 * n }
                .listens { x in "\(x)" }
                .map { x in x.0 + "\(x.1)" }
            
            return x == y
        }
    }
}
