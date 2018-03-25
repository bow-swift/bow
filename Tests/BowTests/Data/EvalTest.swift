//
//  EvalTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class EvalTest: XCTestCase {
    
    var generator : (Int) -> HK<EvalF, Int> {
        return { a in Eval.pure(a) }
    }
    
    var eq = Eval.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
}
