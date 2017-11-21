//
//  CoproductTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class CoproductTest: XCTestCase {
    
    var generator : (Int) -> HK3<CoproductF, IdF, IdF, Int> {
        return { a in Coproduct<IdF, IdF, Int>(Either.pure(Id.pure(a))) }
    }
    
    var eq = Coproduct.eq(Either.eq(Id.eq(Int.order), Id.eq(Int.order)))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
}
