import XCTest
@testable import Bow

class CoproductTest: XCTestCase {
    
    var generator : (Int) -> Coproduct<ForId, ForId, Int> {
        return { a in Coproduct<ForId, ForId, Int>(Either.pure(Id.pure(a))) }
    }
    
    var eq = Coproduct.eq(Either.eq(Id.eq(Int.order), Id.eq(Int.order)))
    var eqUnit = Coproduct.eq(Either.eq(Id.eq(UnitEq()), Id.eq(UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<CoproductPartial<ForId, ForId>>.check(functor: Coproduct<ForId, ForId, Int>.functor(Id<Int>.functor(), Id<Int>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testComonadLaws() {
        ComonadLaws<CoproductPartial<ForId, ForId>>.check(comonad: Coproduct<ForId, ForId, Int>.comonad(Id<Int>.comonad(), Id<Int>.comonad()), generator: self.generator, eq: self.eq)
    }
    
    func testFoldableLaws() {
        FoldableLaws<CoproductPartial<ForId, ForId>>.check(foldable: Coproduct<ForId, ForId, Int>.foldable(Id<Int>.foldable(), Id<Int>.foldable()), generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<CoproductPartial<ForId, ForId>>.check(
            traverse: Coproduct<ForId, ForId, Int>.traverse(Id<Int>.traverse(), Id<Int>.traverse()),
            functor: Coproduct<ForId, ForId, Int>.functor(Id<Int>.functor(), Id<Int>.functor()),
            generator: self.generator,
            eq: self.eq)
    }
}
