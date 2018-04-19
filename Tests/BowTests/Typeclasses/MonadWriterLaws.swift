import Foundation
import SwiftCheck
@testable import Bow

class MonadWriterLaws<F, W> where W : Arbitrary {
    
    static func check<MonWri, MonoW, EqF, EqUnit, EqTuple>(monadWriter : MonWri, monoid : MonoW, eq : EqF, eqUnit : EqUnit, eqTuple: EqTuple) where MonWri : MonadWriter, MonWri.F == F, MonWri.W == W, MonoW : Monoid, MonoW.A == W, EqF : Eq, EqF.A == Kind<F, Int>, EqUnit : Eq, EqUnit.A == Kind<F, ()>, EqTuple : Eq, EqTuple.A == Kind<F, (W, Int)> {
        writerPure(monadWriter, monoid, eq)
        tellFusion(monadWriter, monoid, eqUnit)
        listenPure(monadWriter, monoid, eqTuple)
        listenWriter(monadWriter, monoid, eqTuple)
    }
    
    private static func writerPure<MonWri, MonoW, EqF>(_ monadWriter : MonWri, _ monoid : MonoW, _ eq : EqF) where MonWri : MonadWriter, MonWri.F == F, MonWri.W == W, MonoW : Monoid, MonoW.A == W, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Writer pure") <- forAll { (a : Int) in
            return eq.eqv(monadWriter.writer((monoid.empty, a)),
                          monadWriter.pure(a))
        }
    }
    
    private static func tellFusion<MonWri, MonoW, EqF>(_ monadWriter : MonWri, _ monoid : MonoW, _ eq : EqF) where MonWri : MonadWriter, MonWri.F == F, MonWri.W == W, MonoW : Monoid, MonoW.A == W, EqF : Eq, EqF.A == Kind<F, ()> {
        property("Tell fusion") <- forAll { (a : W, b : W) in
            return eq.eqv(monadWriter.flatMap(monadWriter.tell(a), { _ in monadWriter.tell(b) }),
                          monadWriter.tell(monoid.combine(a, b)))
        }
    }
    
    private static func listenPure<MonWri, MonoW, EqF>(_ monadWriter : MonWri, _ monoid : MonoW, _ eq : EqF) where MonWri : MonadWriter, MonWri.F == F, MonWri.W == W, MonoW : Monoid, MonoW.A == W, EqF : Eq, EqF.A == Kind<F, (W, Int)> {
        property("Listen pure") <- forAll { (a : Int) in
            return eq.eqv(monadWriter.listen(monadWriter.pure(a)),
                          monadWriter.pure((monoid.empty, a)))
        }
    }
    
    private static func listenWriter<MonWri, MonoW, EqF>(_ monadWriter : MonWri, _ monoid : MonoW, _ eq : EqF) where MonWri : MonadWriter, MonWri.F == F, MonWri.W == W, MonoW : Monoid, MonoW.A == W, EqF : Eq, EqF.A == Kind<F, (W, Int)> {
        property("Listen writer") <- forAll { (a : Int, w : W) in
            let tuple = (w, a)
            return eq.eqv(monadWriter.listen(monadWriter.writer(tuple)),
                          monadWriter.map(monadWriter.tell(tuple.0), { _ in tuple }))
        }
    }
}
