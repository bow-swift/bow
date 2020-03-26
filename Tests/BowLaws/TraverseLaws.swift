import SwiftCheck
import Bow
import BowGenerators

public class TraverseLaws<F: Traverse & EquatableK & ArbitraryK> {
    public static func check() {
        identityTraverse()
        sequentialComposition()
        parallelComposition()
        foldMapDerived()
    }
    
    private static func identityTraverse() {
        property("Identity traverse") <~ forAll { (fa: KindOf<F, Int>, y: Int) in
            let f: (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            
            return fa.value.traverse(f)^.value
                ==
            fa.value.map(f).map { a in a^.value }
        }
    }
    
    private static func sequentialComposition() {
        property("Sequential composition") <~ forAll { (f: ArrowOf<Int, Id<Int>>, g: ArrowOf<Int, Id<Int>>, x: KindOf<F, Int>) in
            let fa = x.value.traverse(f.getArrow)
            
            return fa.map { a in a.traverse(g.getArrow) }^.value^.value
                ==
            x.value.traverse { a in
                f.getArrow(a).map(g.getArrow)
            }^.value.map { a in a.value }
        }
    }
    
    private static func parallelComposition() {
        property("Parallel composition") <~ forAll { (f: ArrowOf<Int, Id<Int>>, g: ArrowOf<Int, Id<Int>>, x: KindOf<F, Int>) in
            
            x.value.traverse { a in
                TupleK((f.getArrow(a), g.getArrow(a)))
            }^
                ==
            TupleK((x.value.traverse(f.getArrow)^,
                    x.value.traverse(g.getArrow)^))
        }
    }
    
    private static func foldMapDerived() {
        property("foldMap derived") <~ forAll { (f: ArrowOf<Int, Int>, fa: KindOf<F, Int>) in
            
            fa.value.traverse { a in
                Const<Int, Int>(f.getArrow(a))
            }^.value
                ==
            fa.value.foldMap(f.getArrow)
        }
    }
}

private final class ForTupleK {}
private typealias TupleKOf<A> = Kind<ForTupleK, A>
private class TupleK<A>: TupleKOf<A> {
    let value: (Id<A>, Id<A>)
    
    static func fix(_ value: TupleKOf<A>) -> TupleK<A> {
        value as! TupleK<A>
    }
    
    init(_ value: (Id<A>, Id<A>)) {
        self.value = value
    }
}

private postfix func ^<A>(_ value: TupleKOf<A>) -> TupleK<A> {
    TupleK.fix(value)
}

extension ForTupleK: Applicative {
    static func pure<A>(_ a: A) -> TupleKOf<A> {
        TupleK((Id(a), Id(a)))
    }
    
    static func ap<A, B>(
        _ ff: TupleKOf<(A) -> B>,
        _ fa: TupleKOf<A>) -> Kind<ForTupleK, B> {
        
        TupleK((fa^.value.0.map(ff^.value.0.value)^,
                fa^.value.1.map(ff^.value.1.value)^))
    }
    
    static func map<A, B>(
        _ fa: TupleKOf<A>,
        _ f: @escaping (A) -> B) -> TupleKOf<B> {
        TupleK((fa^.value.0.map(f)^,
                fa^.value.1.map(f)^))
    }
}

extension ForTupleK: EquatableK {
    static func eq<A: Equatable>(
        _ lhs: TupleKOf<A>,
        _ rhs: TupleKOf<A>) -> Bool {
        lhs^.value.0 == rhs^.value.0 &&
        lhs^.value.1 == rhs^.value.1
    }
}
