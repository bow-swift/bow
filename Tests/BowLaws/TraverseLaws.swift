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
        property("Identity traverse") <- forAll { (fa: KindOf<F, Int>, y: Int) in
            let f: (Int) -> Kind<ForId, Int> = { _ in Id<Int>(y) }
            return Id.fix(F.traverse(fa.value, f)).value == F.map(F.map(fa.value, f), { a in Id.fix(a).value })
        }
    }
    
    private static func sequentialComposition() {
        property("Sequential composition") <- forAll { (f: ArrowOf<Int, Id<Int>>, g: ArrowOf<Int, Id<Int>>, x: KindOf<F, Int>) in
            let fa = x.value.traverse(f.getArrow)
            let composed = fa.map { a in a.traverse(g.getArrow) }^.value^.value
            let expected = x.value.traverse { a in f.getArrow(a).map(g.getArrow) }^.value.map { a in a.value }
            return composed == expected
        }
    }
    
    private static func parallelComposition() {
        property("Parallel composition") <- forAll { (f: ArrowOf<Int, Id<Int>>, g: ArrowOf<Int, Id<Int>>, x: KindOf<F, Int>) in
            let actual = TupleK.fix(x.value.traverse { a in TupleK((f.getArrow(a), g.getArrow(a))) })
            let expected = TupleK((x.value.traverse(f.getArrow)^, x.value.traverse(g.getArrow)^))
            return actual == expected
        }
    }
    
    private static func foldMapDerived() {
        property("foldMap derived") <- forAll { (f: ArrowOf<Int, Int>, fa: KindOf<F, Int>) in
            let traversed = fa.value.traverse { a in Const<Int, Int>(f.getArrow(a)) }^.value
            let mapped = fa.value.foldMap(f.getArrow)
            return traversed == mapped
        }
    }
}

private final class ForTupleK {}
private class TupleK<A>: Kind<ForTupleK, A> {
    let value: (Id<A>, Id<A>)
    
    static func fix(_ value: Kind<ForTupleK, A>) -> TupleK<A> {
        return value as! TupleK<A>
    }
    
    init(_ value: (Id<A>, Id<A>)) {
        self.value = value
    }
}

extension ForTupleK: Applicative {
    static func pure<A>(_ a: A) -> Kind<ForTupleK, A> {
        return TupleK((Id(a), Id(a)))
    }
    
    static func ap<A, B>(_ ff: Kind<ForTupleK, (A) -> B>, _ fa: Kind<ForTupleK, A>) -> Kind<ForTupleK, B> {
        let tuplef = TupleK.fix(ff)
        let tuplea = TupleK.fix(fa)
        return TupleK((tuplea.value.0.map(tuplef.value.0.value)^, tuplea.value.1.map(tuplef.value.1.value)^))
    }
    
    static func map<A, B>(_ fa: Kind<ForTupleK, A>, _ f: @escaping (A) -> B) -> Kind<ForTupleK, B> {
        let tuple = TupleK<A>.fix(fa)
        return TupleK((tuple.value.0.map(f)^, tuple.value.1.map(f)^))
    }
}

extension ForTupleK: EquatableK {
    static func eq<A: Equatable>(_ lhs: Kind<ForTupleK, A>, _ rhs: Kind<ForTupleK, A>) -> Bool {
        let x = TupleK.fix(lhs)
        let y = TupleK.fix(rhs)
        return x.value.0 == y.value.0 && x.value.1 == y.value.1
    }
}
