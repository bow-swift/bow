//
//  MonadErrorLaws.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 22/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import CategoryCore

class MonadErrorLaws<F> {
    
    static func check<MonErr, EqF>(monadError : MonErr, eq : EqF) where MonErr : MonadError, MonErr.F == F, MonErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        leftZero(monadError, eq)
        ensureConsistency(monadError, eq)
    }
    
    private static func leftZero<MonErr, EqF>(_ monadError : MonErr, _ eq : EqF) where MonErr : MonadError, MonErr.F == F, MonErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Left zero") <- forAll { (error : CategoryError, a : Int) in
            let f = { (_ : Int) in monadError.pure(a) }
            return eq.eqv(monadError.flatMap(monadError.raiseError(error), f),
                          monadError.raiseError(error))
        }
    }
    
    private static func ensureConsistency<MonErr, EqF>(_ monadError : MonErr, _ eq : EqF) where MonErr : MonadError, MonErr.F == F, MonErr.E == CategoryError, EqF : Eq, EqF.A == HK<F, Int> {
        property("Ensure consistency") <- forAll { (a : Int, error : CategoryError, bool : Bool) in
            let fa = monadError.pure(a)
            let p = { (_ : Int) in bool }
            return eq.eqv(monadError.ensure(fa, error: { error }, predicate: p),
                          monadError.flatMap(fa, { a in p(a) ? monadError.pure(a) : monadError.raiseError(error) }))
        }
    }
    
}
