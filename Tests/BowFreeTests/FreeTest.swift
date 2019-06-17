import XCTest
import Bow
import BowFree
import BowFreeGenerators
@testable import BowLaws

fileprivate final class ForOps {}

extension ForOps: EquatableK {
    static func eq<A>(_ lhs: Kind<ForOps, A>, _ rhs: Kind<ForOps, A>) -> Bool where A : Equatable {
        let x = lhs as! Ops<A>
        let y = rhs as! Ops<A>
        switch (x, y) {
        case (let vx as Value, let vy as Value): return vx.a == vy.a
        case (let ax as Add, let ay as Add): return ax.a == ay.a && ax.b == ay.b
        case (let ox as Subtract, let oy as Subtract): return ox.a == oy.a && ox.b == oy.b
        default:
            return false
        }
    }
}

private class Ops<A>: Kind<ForOps, A> {
    fileprivate static func fix(_ fa: Kind<ForOps, A>) -> Ops<A> {
        return fa as! Ops<A>
    }
    
    fileprivate static func value(_ n: Int) -> Free<ForOps, Int> {
        return Free.liftF(Value(n))
    }
    
    fileprivate static func add(_ a: Int, _ b: Int) -> Free<ForOps, Int> {
        return Free.liftF(Add(a, b))
    }
    
    fileprivate static func subtract(_ a: Int, _ b: Int) -> Free<ForOps, Int> {
        return Free.liftF(Subtract(a, b))
    }
}

fileprivate postfix func ^<A>(_ fa: Kind<ForOps, A>) -> Ops<A> {
    return Ops.fix(fa)
}

private class Value: Ops<Int> {
    let a: Int
    
    init(_ a: Int) {
        self.a = a
    }
}

private class Add: Ops<Int> {
    let a: Int
    let b: Int
    
    init(_ a: Int, _ b: Int) {
        self.a = a
        self.b = b
    }
}

private class Subtract: Ops<Int> {
    let a: Int
    let b: Int
    
    init(_ a: Int, _ b: Int) {
        self.a = a
        self.b = b
    }
}

fileprivate let program = Free.fix(Free<ForOps, Int>.binding({ Ops<Any>.value(10) },
                                                           { value in Ops<Any>.add(value, 10) },
                                                           { _ , added in Ops<Any>.subtract(added, 50) }))

private class OptionInterpreter: FunctionK<ForOps, ForOption> {
    override func invoke<A>(_ fa: Kind<ForOps, A>) -> OptionOf<A> {
        let op = Ops.fix(fa)
        switch op {
        case let value as Value: return Option<Int>.pure(value.a) as! Kind<ForOption, A>
        case let add as Add: return Option<Int>.pure(add.a + add.b) as! Kind<ForOption, A>
        case let subtract as Subtract: return Option<Int>.pure(subtract.a - subtract.b) as! Kind<ForOption, A>
        default:
            fatalError("No other options")
        }
    }
}

private class IdInterpreter: FunctionK<ForOps, ForId> {
    override func invoke<A>(_ fa: Kind<ForOps, A>) -> IdOf<A> {
        let op = Ops.fix(fa)
        switch op {
        case let value as Value: return Id<Int>.pure(value.a) as! IdOf<A>
        case let add as Add: return Id<Int>.pure(add.a + add.b) as! IdOf<A>
        case let subtract as Subtract: return Id<Int>.pure(subtract.a - subtract.b) as! IdOf<A>
        default:
            fatalError("No other options")
        }
    }
}

extension FreePartial: EquatableK where S: Monad & EquatableK {
    public static func eq<A>(_ lhs: Kind<FreePartial<S>, A>, _ rhs: Kind<FreePartial<S>, A>) -> Bool where A : Equatable {
        return Free.fix(lhs).run() == Free.fix(rhs).run()
    }
}

class FreeTest: XCTestCase {
    func testInterpretsFreeProgram() {
        let x = program.foldMapK(OptionInterpreter())
        let y = program.foldMapK(IdInterpreter())
        XCTAssertEqual(x, Option.some(-30))
        XCTAssertEqual(y, Id.pure(-30))
    }
    
    func testFunctorLaws() {
        FunctorLaws<FreePartial<ForId>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<FreePartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<FreePartial<ForId>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<FreePartial<ForId>>.check()
    }
}
