//
//  StringInstances.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 14/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class StringConcatSemigroup : Semigroup {
    public typealias A = String
    
    public func combine(_ a : String, _ b : String) -> String {
        return a + b
    }
}

public class StringConcatMonoid : StringConcatSemigroup, Monoid {
    public var empty : String {
        return ""
    }
}

public extension String {
    public static var concatMonoid : StringConcatMonoid {
        return StringConcatMonoid()
    }
}
