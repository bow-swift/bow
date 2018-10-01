import XCTest
@testable import Bow

fileprivate class OpsF {}

fileprivate class Ops<A> : Kind<OpsF, A> {
    fileprivate static func fix(_ fa : Kind<OpsF, A>) -> Ops<A> {
        return fa as! Ops<A>
    }
    
    fileprivate static func value(_ n : Int) -> Free<OpsF, Int> {
        return Free.liftF(Value(n))
    }
    
    fileprivate static func add(_ a : Int, _ b : Int) -> Free<OpsF, Int> {
        return Free.liftF(Add(a, b))
    }
    
    fileprivate static func subtract(_ a : Int, _ b : Int) -> Free<OpsF, Int> {
        return Free.liftF(Subtract(a, b))
    }
}

fileprivate class Value : Ops<Int> {
    let a : Int
    
    init(_ a : Int) {
        self.a = a
    }
}

fileprivate class Add : Ops<Int> {
    let a : Int
    let b : Int
    
    init(_ a : Int, _ b : Int) {
        self.a = a
        self.b = b
    }
}

fileprivate class Subtract : Ops<Int> {
    let a : Int
    let b : Int
    
    init(_ a : Int, _ b : Int) {
        self.a = a
        self.b = b
    }
}



fileprivate let program = Free.fix(Free<OpsF, Int>.monad().binding({ Ops<Any>.value(10) },
                                                                  { value in Ops<Any>.add(value, 10) },
                                                                  { _ , added in Ops<Any>.subtract(added, 50) }))

fileprivate class OptionInterpreter : FunctionK {
    fileprivate typealias F = OpsF
    fileprivate typealias G = ForOption
    
    fileprivate func invoke<A>(_ fa: Kind<OpsF, A>) -> OptionOf<A> {
        let op = Ops.fix(fa)
        switch op {
        case is Value: return Option<Int>.some((op as! Value).a) as! OptionOf<A>
        case is Add: return Option<Int>.some((op as! Add).a + (op as! Add).b) as! OptionOf<A>
        case is Subtract: return Option<Int>.some((op as! Subtract).a - (op as! Subtract).b) as! OptionOf<A>
        default:
            fatalError("No other options")
        }
    }
}

fileprivate class IdInterpreter : FunctionK {
    fileprivate typealias F = OpsF
    fileprivate typealias G = ForId
    
    fileprivate func invoke<A>(_ fa: Kind<OpsF, A>) -> IdOf<A> {
        let op = Ops.fix(fa)
        switch op {
        case is Value: return Id<Int>.pure((op as! Value).a) as! IdOf<A>
        case is Add: return Id<Int>.pure((op as! Add).a + (op as! Add).b) as! IdOf<A>
        case is Subtract: return Id<Int>.pure((op as! Subtract).a - (op as! Subtract).b) as! IdOf<A>
        default:
            fatalError("No other options")
        }
    }
}

class FreeTest: XCTestCase {
    
    func testInterpretsFreeProgram() {
        let x = program.foldMap(OptionInterpreter(), Option<Int>.monad())
        let y = program.foldMap(IdInterpreter(), Id<Int>.monad())
        XCTAssertTrue(Option.eq(Int.order).eqv(x, Option.some(-30)))
        XCTAssertTrue(Id.eq(Int.order).eqv(y, Id.pure(-30)))
    }
    
    fileprivate var generator : (Int) -> FreeOf<OpsF, Int> {
        return { a in Ops<Any>.value(a) }
    }
    
    fileprivate let eq = Free<OpsF, Int>.eq(IdInterpreter(), Id<Int>.monad(), Id.eq(Int.order))
    fileprivate let eqUnit = Free<OpsF, ()>.eq(IdInterpreter(), Id<Int>.monad(), Id.eq(UnitEq()))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<FreePartial<OpsF>>.check(functor: Free<OpsF, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<FreePartial<OpsF>>.check(applicative: Free<OpsF, Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<FreePartial<OpsF>>.check(monad: Free<OpsF, Int>.monad(), eq: self.eq)
    }
}
