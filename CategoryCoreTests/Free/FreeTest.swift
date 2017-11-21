//
//  FreeTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

fileprivate class OpsF {}

fileprivate class Ops<A> : HK<OpsF, A> {
    static func ev(_ fa : HK<OpsF, A>) -> Ops<A> {
        return fa as! Ops<A>
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

fileprivate func value(_ n : Int) -> Free<OpsF, Int> {
    return Free.liftF(Value(n))
}

fileprivate func add(_ a : Int, _ b : Int) -> Free<OpsF, Int> {
    return Free.liftF(Add(a, b))
}

fileprivate func subtract(_ a : Int, _ b : Int) -> Free<OpsF, Int> {
    return Free.liftF(Subtract(a, b))
}

fileprivate let program = Free.ev(Free<OpsF, Int>.monad().binding({ value(10) },
                                                                  { value in add(value, 10) },
                                                                  { _ , added in subtract(added, 50) }))

fileprivate class MaybeInterpreter : FunctionK {
    fileprivate typealias F = OpsF
    fileprivate typealias G = MaybeF
    
    fileprivate func invoke<A>(_ fa: HK<OpsF, A>) -> HK<MaybeF, A> {
        let op = Ops.ev(fa)
        switch op {
        case is Value: return Maybe<Int>.some((op as! Value).a) as! HK<MaybeF, A>
        case is Add: return Maybe<Int>.some((op as! Add).a + (op as! Add).b) as! HK<MaybeF, A>
        case is Subtract: return Maybe<Int>.some((op as! Subtract).a - (op as! Subtract).b) as! HK<MaybeF, A>
        default:
            fatalError("No other options")
        }
    }
}

fileprivate class IdInterpreter : FunctionK {
    fileprivate typealias F = OpsF
    fileprivate typealias G = IdF
    
    fileprivate func invoke<A>(_ fa: HK<OpsF, A>) -> HK<IdF, A> {
        let op = Ops.ev(fa)
        switch op {
        case is Value: return Id<Int>.pure((op as! Value).a) as! HK<IdF, A>
        case is Add: return Id<Int>.pure((op as! Add).a + (op as! Add).b) as! HK<IdF, A>
        case is Subtract: return Id<Int>.pure((op as! Subtract).a - (op as! Subtract).b) as! HK<IdF, A>
        default:
            fatalError("No other options")
        }
    }
}

class FreeTest: XCTestCase {
    
    func testInterpretsFreeProgram() {
        let x = program.foldMap(MaybeInterpreter(), Maybe<Int>.monad())
        let y = program.foldMap(IdInterpreter(), Id<Int>.monad())
        XCTAssertTrue(Maybe.eq(Int.order).eqv(x, Maybe.some(-30)))
        XCTAssertTrue(Id.eq(Int.order).eqv(y, Id.pure(-30)))
    }
}
