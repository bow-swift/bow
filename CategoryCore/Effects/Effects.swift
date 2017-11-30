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
}
