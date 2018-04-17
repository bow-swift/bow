//
//  MonadStateLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 24/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import Bow

class MonadStateLaws<F> {
    
    static func check<MonSt, EqF, EqUnit>(monadState : MonSt, eq : EqF, eqUnit : EqUnit) where MonSt : MonadState, MonSt.F == F, MonSt.S == Int, EqF : Eq, EqF.A == Kind<F, Int>, EqUnit : Eq, EqUnit.A == Kind<F, ()> {
        getIdempotent(monadState, eq)
        setTwice(monadState, eqUnit)
        setGet(monadState, eq)
        getSet(monadState, eqUnit)
    }
    
    private static func getIdempotent<MonSt, EqF>(_ monadState : MonSt, _ eq : EqF) where MonSt : MonadState, MonSt.F == F, MonSt.S == Int, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Idempotence") <- forAll { (_ : Int) in
            return eq.eqv(monadState.flatMap(monadState.get(), { _ in monadState.get() }),
                          monadState.get())
        }
    }
    
    private static func setTwice<MonSt, EqF>(_ monadState : MonSt, _ eq : EqF) where MonSt : MonadState, MonSt.F == F, MonSt.S == Int, EqF : Eq, EqF.A == Kind<F, ()> {
        property("Set twice is equivalent to set only the second") <- forAll { (s : Int, t : Int) in
            return eq.eqv(monadState.flatMap(monadState.set(s), { _ in monadState.set(t) }),
                          monadState.set(t))
        }
    }
    
    private static func setGet<MonSt, EqF>(_ monadState : MonSt, _ eq : EqF) where MonSt : MonadState, MonSt.F == F, MonSt.S == Int, EqF : Eq, EqF.A == Kind<F, Int> {
        property("Get after set retrieves the original value") <- forAll { (s : Int) in
            return eq.eqv(monadState.flatMap(monadState.set(s), { _ in monadState.get() }),
                          monadState.flatMap(monadState.set(s), { _ in monadState.pure(s) }))
        }
    }
    
    private static func getSet<MonSt, EqF>(_ monadState : MonSt, _ eq : EqF) where MonSt : MonadState, MonSt.F == F, MonSt.S == Int, EqF : Eq, EqF.A == Kind<F, ()> {
        property("Get set") <- forAll { (_ : Int) in
            return eq.eqv(monadState.flatMap(monadState.get(), monadState.set),
                          monadState.pure(()))
        }
    }
}
