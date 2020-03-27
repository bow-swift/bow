import SwiftCheck
import Bow

public class MonadStateLaws<F: MonadState & EquatableK> where F.S == Int {
    public static func check() {
        getIdempotent()
        setTwice()
        setGet()
        getSet()
        comprehensions()
    }
    
    private static func getIdempotent() {
        property("Idempotence") <~ forAll { (_: Int) in
            
            F.get().flatMap { _ in F.get() }
                ==
            F.get()
        }
    }
    
    private static func setTwice() {
        property("Set twice is equivalent to set only the second") <~ forAll { (s: Int, t: Int) in
            
            isEqual(
                F.set(s).flatMap { _ in F.set(t) },
                F.set(t))
        }
    }
    
    private static func setGet() {
        property("Get after set retrieves the original value") <~ forAll { (s: Int) in
            
            F.set(s).flatMap { _ in F.get() }
                ==
            F.set(s).flatMap { _ in F.pure(s) }
        }
    }
    
    private static func getSet() {
        property("Get set") <~ forAll { (_: Int) in
            
            isEqual(
                F.get().flatMap(F.set),
                F.pure(()))
        }
    }
    
    private static func comprehensions() {
        property("Set twice") <~ forAll { (s: Int, t: Int) in
            let x: Kind<F, Void> = binding(
                setState(s),
                setState(t),
                yield: ())
            let y = F.set(t)
            return isEqual(x, y)
        }
        
        property("Get after set") <~ forAll { (s: Int) in
            let a = F.var(Int.self)
            
            let x: Kind<F, Int> = binding(
                setState(s),
                a <-- getState(),
                yield: a.get)
            let y = F.set(s).flatMap { _ in F.pure(s) }
            
            return x == y
        }
        
        property("Modify state") <~ forAll { (s: Int) in
            let a = F.var(Int.self)
            let b = F.var(String.self)
            
            let x = binding(
                setState(s),
                modifyState { x in 2 * x },
                a <-- getState(),
                b <-- inspectState { x in "State: \(x)" },
                yield: b.get)
            
            let y = F.set(2 * s).flatMap { _ in F.pure("State: \(2 * s)") }
            
            return x == y
        }
    }
}
