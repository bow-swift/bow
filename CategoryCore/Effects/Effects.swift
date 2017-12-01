//
//  Effects.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

class Effects {
    static func onceOnly<A>(_ f : @escaping (A) throws -> Unit) -> (A) throws -> Unit {
        var wasCalled = false
        
        return { a in
            try synced(self) {
                if !wasCalled {
                    wasCalled = true
                    return try f(a)
                }
            }
        }
    }
    
    static func unsafeResync<A>(_ io : IO<A>) -> Maybe<A> {
        var ref = Maybe<Either<Error, A>>.none()
        io.unsafeRunAsync { result in
            ref = Maybe.some(result)
        }
        
        while(ref.isEmpty) {}
        
        return ref.fold(constF(Maybe.none()),
                        { either in either.fold(constF(Maybe.none()),
                                                Maybe.some) })
    }
}
