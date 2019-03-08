import SwiftCheck
@testable import Bow

public class SelectiveLaws<F: Selective & EquatableK> {
    public static func check() {
        identity()
        distributibity()
        associativity()
    }

    private static func identity() {
        property("Identity") <- forAll { (x: Int) in
            let input = F.pure(Either<Int, Int>.right(x))
            return F.select(input, F.pure(id)) ==
                F.map(input) { x in x.fold(id, id) }
        }
    }

    private static func distributibity() {
        property("Distributivity") <- forAll { (a: Int, b: ArrowOf<Int, Int>, c: ArrowOf<Int, Int>) in
            let x = F.pure(Either<Int, Int>.right(a))
            let f = F.pure(b.getArrow)
            let g = F.pure(c.getArrow)
            return F.select(x, F.sequenceRight(f, g)) == F.sequenceRight(F.select(x, f), F.select(x, g))
        }
    }

    private static func associativity() {
        property("Associativity") <- forAll { (a: Int, b: ArrowOf<Int, Int>, c: ArrowOf<Int, Int>) in
            let x = F.pure(Either<Int, Int>.right(a))
            let y = F.pure(Either<Int, (Int) -> Int>.right(b.getArrow))
            let z = F.pure({ (_: Int) in c.getArrow })

            let m : Kind<F, Either<Int, Either<(Int, Int), Int>>> = F.map(x) { x in Either.fix(x.map(Either<(Int, Int), Int>.right)) }
            let n : Kind<F, (Int) -> Either<(Int, Int), Int>> = F.map(y) { y in { a in y.bimap({ l in (l, a) }, { r in r(a) }) }}
            let q : Kind<F, ((Int, Int)) -> Int> = F.map(z) { z in { a in z(a.0)(a.1) } }

            return F.select(x, F.select(y, z)) ==
                F.select(F.select(m, n), q)
        }
    }
}
