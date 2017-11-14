//
//  NumberInstances.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 14/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

// Int

public class IntSumSemigroup : Semigroup {
    public typealias A = Int
    
    public func combine(_ a : Int, _ b : Int) -> Int {
        return a + b
    }
}

public class IntSumMonoid : IntSumSemigroup, Monoid {
    public var empty : Int {
        return 0
    }
}

public class IntProductSemigroup : Semigroup {
    public typealias A = Int
    
    public func combine(_ a : Int, _ b : Int) -> Int {
        return a * b
    }
}

public class IntProductMonoid : IntProductSemigroup, Monoid {
    public var empty : Int {
        return 1
    }
}

public extension Int {
    public static var sumMonoid : IntSumMonoid {
        return IntSumMonoid()
    }
    
    public static var productMonoid : IntProductMonoid {
        return IntProductMonoid()
    }
}

// Int8

public class Int8SumSemigroup : Semigroup {
    public typealias A = Int8
    
    public func combine(_ a : Int8, _ b : Int8) -> Int8 {
        return a + b
    }
}

public class Int8SumMonoid : Int8SumSemigroup, Monoid {
    public var empty : Int8 {
        return 0
    }
}

public class Int8ProductSemigroup : Semigroup {
    public typealias A = Int8
    
    public func combine(_ a : Int8, _ b : Int8) -> Int8 {
        return a * b
    }
}

public class Int8ProductMonoid : Int8ProductSemigroup, Monoid {
    public var empty : Int8 {
        return 1
    }
}

public extension Int8 {
    public static var sumMonoid : Int8SumMonoid {
        return Int8SumMonoid()
    }
    
    public static var productMonoid : Int8ProductMonoid {
        return Int8ProductMonoid()
    }
}

// Int16

public class Int16SumSemigroup : Semigroup {
    public typealias A = Int16
    
    public func combine(_ a : Int16, _ b : Int16) -> Int16 {
        return a + b
    }
}

public class Int16SumMonoid : Int16SumSemigroup, Monoid {
    public var empty : Int16 {
        return 0
    }
}

public class Int16ProductSemigroup : Semigroup {
    public typealias A = Int16
    
    public func combine(_ a : Int16, _ b : Int16) -> Int16 {
        return a * b
    }
}

public class Int16ProductMonoid : Int16ProductSemigroup, Monoid {
    public var empty : Int16 {
        return 1
    }
}

public extension Int16 {
    public static var sumMonoid : Int16SumMonoid {
        return Int16SumMonoid()
    }
    
    public static var productMonoid : Int16ProductMonoid {
        return Int16ProductMonoid()
    }
}

// Int32

public class Int32SumSemigroup : Semigroup {
    public typealias A = Int32
    
    public func combine(_ a : Int32, _ b : Int32) -> Int32 {
        return a + b
    }
}

public class Int32SumMonoid : Int32SumSemigroup, Monoid {
    public var empty : Int32 {
        return 0
    }
}

public class Int32ProductSemigroup : Semigroup {
    public typealias A = Int32
    
    public func combine(_ a : Int32, _ b : Int32) -> Int32 {
        return a * b
    }
}

public class Int32ProductMonoid : Int32ProductSemigroup, Monoid {
    public var empty : Int32 {
        return 1
    }
}

public extension Int32 {
    public static var sumMonoid : Int32SumMonoid {
        return Int32SumMonoid()
    }
    
    public static var productMonoid : Int32ProductMonoid {
        return Int32ProductMonoid()
    }
}

// Int64

public class Int64SumSemigroup : Semigroup {
    public typealias A = Int64
    
    public func combine(_ a : Int64, _ b : Int64) -> Int64 {
        return a + b
    }
}

public class Int64SumMonoid : Int64SumSemigroup, Monoid {
    public var empty : Int64 {
        return 0
    }
}

public class Int64ProductSemigroup : Semigroup {
    public typealias A = Int64
    
    public func combine(_ a : Int64, _ b : Int64) -> Int64 {
        return a * b
    }
}

public class Int64ProductMonoid : Int64ProductSemigroup, Monoid {
    public var empty : Int64 {
        return 1
    }
}

public extension Int64 {
    public static var sumMonoid : Int64SumMonoid {
        return Int64SumMonoid()
    }
    
    public static var productMonoid : Int64ProductMonoid {
        return Int64ProductMonoid()
    }
}

// UInt

public class UIntSumSemigroup : Semigroup {
    public typealias A = UInt
    
    public func combine(_ a : UInt, _ b : UInt) -> UInt {
        return a + b
    }
}

public class UIntSumMonoid : UIntSumSemigroup, Monoid {
    public var empty : UInt {
        return 0
    }
}

public class UIntProductSemigroup : Semigroup {
    public typealias A = UInt
    
    public func combine(_ a : UInt, _ b : UInt) -> UInt {
        return a * b
    }
}

public class UIntProductMonoid : UIntProductSemigroup, Monoid {
    public var empty : UInt {
        return 1
    }
}

public extension UInt {
    public static var sumMonoid : UIntSumMonoid {
        return UIntSumMonoid()
    }
    
    public static var productMonoid : UIntProductMonoid {
        return UIntProductMonoid()
    }
}

// UInt8

public class UInt8SumSemigroup : Semigroup {
    public typealias A = UInt8
    
    public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
        return a + b
    }
}

public class UInt8SumMonoid : UInt8SumSemigroup, Monoid {
    public var empty : UInt8 {
        return 0
    }
}

public class UInt8ProductSemigroup : Semigroup {
    public typealias A = UInt8
    
    public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
        return a * b
    }
}

public class UInt8ProductMonoid : UInt8ProductSemigroup, Monoid {
    public var empty : UInt8 {
        return 1
    }
}

public extension UInt8 {
    public static var sumMonoid : UInt8SumMonoid {
        return UInt8SumMonoid()
    }
    
    public static var productMonoid : UInt8ProductMonoid {
        return UInt8ProductMonoid()
    }
}

// UInt16

public class UInt16SumSemigroup : Semigroup {
    public typealias A = UInt16
    
    public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
        return a + b
    }
}

public class UInt16SumMonoid : UInt16SumSemigroup, Monoid {
    public var empty : UInt16 {
        return 0
    }
}

public class UInt16ProductSemigroup : Semigroup {
    public typealias A = UInt16
    
    public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
        return a * b
    }
}

public class UInt16ProductMonoid : UInt16ProductSemigroup, Monoid {
    public var empty : UInt16 {
        return 1
    }
}

public extension UInt16 {
    public static var sumMonoid : UInt16SumMonoid {
        return UInt16SumMonoid()
    }
    
    public static var productMonoid : UInt16ProductMonoid {
        return UInt16ProductMonoid()
    }
}

// Int32

public class UInt32SumSemigroup : Semigroup {
    public typealias A = UInt32
    
    public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
        return a + b
    }
}

public class UInt32SumMonoid : UInt32SumSemigroup, Monoid {
    public var empty : UInt32 {
        return 0
    }
}

public class UInt32ProductSemigroup : Semigroup {
    public typealias A = UInt32
    
    public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
        return a * b
    }
}

public class UInt32ProductMonoid : UInt32ProductSemigroup, Monoid {
    public var empty : UInt32 {
        return 1
    }
}

public extension UInt32 {
    public static var sumMonoid : UInt32SumMonoid {
        return UInt32SumMonoid()
    }
    
    public static var productMonoid : UInt32ProductMonoid {
        return UInt32ProductMonoid()
    }
}

// Int64

public class UInt64SumSemigroup : Semigroup {
    public typealias A = UInt64
    
    public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
        return a + b
    }
}

public class UInt64SumMonoid : UInt64SumSemigroup, Monoid {
    public var empty : UInt64 {
        return 0
    }
}

public class UInt64ProductSemigroup : Semigroup {
    public typealias A = UInt64
    
    public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
        return a * b
    }
}

public class UInt64ProductMonoid : UInt64ProductSemigroup, Monoid {
    public var empty : UInt64 {
        return 1
    }
}

public extension UInt64 {
    public static var sumMonoid : UInt64SumMonoid {
        return UInt64SumMonoid()
    }
    
    public static var productMonoid : UInt64ProductMonoid {
        return UInt64ProductMonoid()
    }
}

// Float

public class FloatSumSemigroup : Semigroup {
    public typealias A = Float
    
    public func combine(_ a : Float, _ b : Float) -> Float {
        return a + b
    }
}

public class FloatSumMonoid : FloatSumSemigroup, Monoid {
    public var empty : Float {
        return 0
    }
}

public class FloatProductSemigroup : Semigroup {
    public typealias A = Float
    
    public func combine(_ a : Float, _ b : Float) -> Float {
        return a * b
    }
}

public class FloatProductMonoid : FloatProductSemigroup, Monoid {
    public var empty : Float {
        return 1
    }
}

public extension Float {
    public static var sumMonoid : FloatSumMonoid {
        return FloatSumMonoid()
    }
    
    public static var productMonoid : FloatProductMonoid {
        return FloatProductMonoid()
    }
}

// Double

public class DoubleSumSemigroup : Semigroup {
    public typealias A = Double
    
    public func combine(_ a : Double, _ b : Double) -> Double {
        return a + b
    }
}

public class DoubleSumMonoid : DoubleSumSemigroup, Monoid {
    public var empty : Double {
        return 0
    }
}

public class DoubleProductSemigroup : Semigroup {
    public typealias A = Double
    
    public func combine(_ a : Double, _ b : Double) -> Double {
        return a * b
    }
}

public class DoubleProductMonoid : DoubleProductSemigroup, Monoid {
    public var empty : Double {
        return 1
    }
}

public extension Double {
    public static var sumMonoid : DoubleSumMonoid {
        return DoubleSumMonoid()
    }
    
    public static var productMonoid : DoubleProductMonoid {
        return DoubleProductMonoid()
    }
}
