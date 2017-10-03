//
//  BooleanFunctions.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 3/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public func not(_ a : Bool) -> Bool {
    return !a
}

public func and(_ a : Bool, _ b : Bool) -> Bool {
    return a && b
}

public func or(_ a : Bool, _ b : Bool) -> Bool {
    return a || b
}

public func xor(_ a : Bool, _ b : Bool) -> Bool {
    return a != b
}
