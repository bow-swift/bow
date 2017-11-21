//
//  WriterTTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class WriterTTest: XCTestCase {
    
    var generator : (Int) -> HK3<WriterTF, IdF, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    var eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
}
