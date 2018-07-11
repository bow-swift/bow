import XCTest
@testable import Bow

class IorTest: XCTestCase {
    var generator = { (a : Int) -> Ior<Int, Int> in
        switch a % 3 {
        case 0 : return Ior.left(a)
        case 1: return Ior.right(a)
        default: return Ior.both(a, a)
        }
    }
    
    let eq = Ior.eq(Int.order, Int.order)
    let eqUnit = Ior.eq(Int.order, UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check(functor: Ior<Int, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IorPartial<Int>>.check(applicative: Ior<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IorPartial<Int>>.check(monad: Ior<Int, Int>.monad(Int.sumMonoid), eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Ior.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<IorPartial<Int>>.check(foldable: Ior<Int, Int>.foldable(), generator: self.generator)
    }
}
