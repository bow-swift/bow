//
//  StringInstances.swift
//  Bow
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

public class StringEq : Eq {
    public typealias A = String
    
    public func eqv(_ a: String, _ b: String) -> Bool {
        return a == b
    }
}

public class StringOrder : StringEq, Order {
    public func compare(_ a: String, _ b: String) -> Int {
        switch a.compare(b) {
        case .orderedAscending: return -1
        case .orderedDescending: return 1
        case .orderedSame: return 0
        }
    }
}

public extension String {
    public static var concatMonoid : StringConcatMonoid {
        return StringConcatMonoid()
    }
    
    public static var order : StringOrder {
        return StringOrder()
    }
}
