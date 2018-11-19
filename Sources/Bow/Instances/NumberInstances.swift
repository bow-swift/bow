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

public class IntEq : Eq {
    public typealias A = Int
    
    public func eqv(_ a: Int, _ b: Int) -> Bool {
        return a == b
    }
}

public class IntOrder : IntEq, Order {
    public func compare(_ a: Int, _ b: Int) -> Int {
        return a - b
    }
}

public extension Int {
    public static var sumSemigroup : IntSumSemigroup {
        return IntSumSemigroup()
    }
    
    public static var sumMonoid : IntSumMonoid {
        return IntSumMonoid()
    }
    
    public static var productSemigroup : IntProductSemigroup {
        return IntProductSemigroup()
    }
    
    public static var productMonoid : IntProductMonoid {
        return IntProductMonoid()
    }
    
    public static var eq : IntEq {
        return IntEq()
    }
    
    public static var order : IntOrder {
        return IntOrder()
    }
}

// Int8

public class Int8SumSemigroup : Semigroup {
    public typealias A = Int8
    
    public func combine(_ a : Int8, _ b : Int8) -> Int8 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class Int8ProductMonoid : Int8ProductSemigroup, Monoid {
    public var empty : Int8 {
        return 1
    }
}

public class Int8Eq : Eq {
    public typealias A = Int8
    
    public func eqv(_ a: Int8, _ b: Int8) -> Bool {
        return a == b
    }
}

public class Int8Order : Int8Eq, Order {
    public func compare(_ a: Int8, _ b: Int8) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int8 {
    public static var sumSemigroup : Int8SumSemigroup {
        return Int8SumSemigroup()
    }
    
    public static var sumMonoid : Int8SumMonoid {
        return Int8SumMonoid()
    }
    
    public static var productSemigroup : Int8ProductSemigroup {
        return Int8ProductSemigroup()
    }
    
    public static var productMonoid : Int8ProductMonoid {
        return Int8ProductMonoid()
    }
    
    public static var eq : Int8Eq {
        return Int8Eq()
    }
    
    public static var order : Int8Order {
        return Int8Order()
    }
}

// Int16

public class Int16SumSemigroup : Semigroup {
    public typealias A = Int16
    
    public func combine(_ a : Int16, _ b : Int16) -> Int16 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class Int16ProductMonoid : Int16ProductSemigroup, Monoid {
    public var empty : Int16 {
        return 1
    }
}

public class Int16Eq : Eq {
    public typealias A = Int16
    
    public func eqv(_ a: Int16, _ b: Int16) -> Bool {
        return a == b
    }
}

public class Int16Order : Int16Eq, Order {
    public func compare(_ a: Int16, _ b: Int16) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int16 {
    public static var sumSemigroup : Int16SumSemigroup {
        return Int16SumSemigroup()
    }
    
    public static var sumMonoid : Int16SumMonoid {
        return Int16SumMonoid()
    }
    
    public static var productSemigroup : Int16ProductSemigroup {
        return Int16ProductSemigroup()
    }
    
    public static var productMonoid : Int16ProductMonoid {
        return Int16ProductMonoid()
    }
    
    public static var eq : Int16Eq {
        return Int16Eq()
    }
    
    public static var order : Int16Order {
        return Int16Order()
    }
}

// Int32

public class Int32SumSemigroup : Semigroup {
    public typealias A = Int32
    
    public func combine(_ a : Int32, _ b : Int32) -> Int32 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class Int32ProductMonoid : Int32ProductSemigroup, Monoid {
    public var empty : Int32 {
        return 1
    }
}

public class Int32Eq : Eq {
    public typealias A = Int32
    
    public func eqv(_ a: Int32, _ b: Int32) -> Bool {
        return a == b
    }
}

public class Int32Order : Int32Eq, Order {
    public func compare(_ a: Int32, _ b: Int32) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int32 {
    public static var sumSemigroup : Int32SumSemigroup {
        return Int32SumSemigroup()
    }
    
    public static var sumMonoid : Int32SumMonoid {
        return Int32SumMonoid()
    }

    public static var productSemigroup : Int32ProductSemigroup {
        return Int32ProductSemigroup()
    }
    
    public static var productMonoid : Int32ProductMonoid {
        return Int32ProductMonoid()
    }
    
    public static var eq : Int32Eq {
        return Int32Eq()
    }
    
    public static var order : Int32Order {
        return Int32Order()
    }
}

// Int64

public class Int64SumSemigroup : Semigroup {
    public typealias A = Int64
    
    public func combine(_ a : Int64, _ b : Int64) -> Int64 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class Int64ProductMonoid : Int64ProductSemigroup, Monoid {
    public var empty : Int64 {
        return 1
    }
}

public class Int64Eq : Eq {
    public typealias A = Int64
    
    public func eqv(_ a: Int64, _ b: Int64) -> Bool {
        return a == b
    }
}

public class Int64Order : Int64Eq, Order {
    public func compare(_ a: Int64, _ b: Int64) -> Int {
        return Int(a) - Int(b)
    }
}

public extension Int64 {
    public static var sumSemigroup : Int64SumSemigroup {
        return Int64SumSemigroup()
    }
    
    public static var sumMonoid : Int64SumMonoid {
        return Int64SumMonoid()
    }
    
    public static var productSemigroup : Int64ProductSemigroup {
        return Int64ProductSemigroup()
    }
    
    public static var productMonoid : Int64ProductMonoid {
        return Int64ProductMonoid()
    }
    
    public static var eq : Int64Eq {
        return Int64Eq()
    }
    
    public static var order : Int64Order {
        return Int64Order()
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

public class UIntEq : Eq {
    public typealias A = UInt
    
    public func eqv(_ a: UInt, _ b: UInt) -> Bool {
        return a == b
    }
}

public class UIntOrder : UIntEq, Order {
    public func compare(_ a: UInt, _ b: UInt) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt {
    public static var sumSemigroup : UIntSumSemigroup {
        return UIntSumSemigroup()
    }
    
    public static var sumMonoid : UIntSumMonoid {
        return UIntSumMonoid()
    }
    
    public static var productSemigroup : UIntProductSemigroup {
        return UIntProductSemigroup()
    }
    
    public static var productMonoid : UIntProductMonoid {
        return UIntProductMonoid()
    }
    
    public static var eq : UIntEq {
        return UIntEq()
    }
    
    public static var order : UIntOrder {
        return UIntOrder()
    }
}

// UInt8

public class UInt8SumSemigroup : Semigroup {
    public typealias A = UInt8
    
    public func combine(_ a : UInt8, _ b : UInt8) -> UInt8 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class UInt8ProductMonoid : UInt8ProductSemigroup, Monoid {
    public var empty : UInt8 {
        return 1
    }
}

public class UInt8Eq : Eq {
    public typealias A = UInt8
    
    public func eqv(_ a: UInt8, _ b: UInt8) -> Bool {
        return a == b
    }
}

public class UInt8Order : UInt8Eq, Order {
    public func compare(_ a: UInt8, _ b: UInt8) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt8 {
    public static var sumSemigroup : UInt8SumSemigroup {
        return UInt8SumSemigroup()
    }
    
    public static var sumMonoid : UInt8SumMonoid {
        return UInt8SumMonoid()
    }
    
    public static var productSemigroup : UIntProductSemigroup {
        return UIntProductSemigroup()
    }
    
    public static var productMonoid : UInt8ProductMonoid {
        return UInt8ProductMonoid()
    }
    
    public static var eq : UInt8Eq {
        return UInt8Eq()
    }
    
    public static var order : UInt8Order {
        return UInt8Order()
    }
}

// UInt16

public class UInt16SumSemigroup : Semigroup {
    public typealias A = UInt16
    
    public func combine(_ a : UInt16, _ b : UInt16) -> UInt16 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class UInt16ProductMonoid : UInt16ProductSemigroup, Monoid {
    public var empty : UInt16 {
        return 1
    }
}

public class UInt16Eq : Eq {
    public typealias A = UInt16
    
    public func eqv(_ a: UInt16, _ b: UInt16) -> Bool {
        return a == b
    }
}

public class UInt16Order : UInt16Eq, Order {
    public func compare(_ a: UInt16, _ b: UInt16) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt16 {
    public static var sumSemigroup : UInt16SumSemigroup {
        return UInt16SumSemigroup()
    }
    
    public static var sumMonoid : UInt16SumMonoid {
        return UInt16SumMonoid()
    }
    
    public static var productSemigroup : UInt16ProductSemigroup {
        return UInt16ProductSemigroup()
    }
    
    public static var productMonoid : UInt16ProductMonoid {
        return UInt16ProductMonoid()
    }
    
    public static var eq : UInt16Eq {
        return UInt16Eq()
    }
    
    public static var order : UInt16Order {
        return UInt16Order()
    }
}

// UInt32

public class UInt32SumSemigroup : Semigroup {
    public typealias A = UInt32
    
    public func combine(_ a : UInt32, _ b : UInt32) -> UInt32 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class UInt32ProductMonoid : UInt32ProductSemigroup, Monoid {
    public var empty : UInt32 {
        return 1
    }
}

public class UInt32Eq : Eq {
    public typealias A = UInt32
    
    public func eqv(_ a: UInt32, _ b: UInt32) -> Bool {
        return a == b
    }
}

public class UInt32Order : UInt32Eq, Order {
    public func compare(_ a: UInt32, _ b: UInt32) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt32 {
    public static var sumSemigroup : UInt32SumSemigroup {
        return UInt32SumSemigroup()
    }
    
    public static var sumMonoid : UInt32SumMonoid {
        return UInt32SumMonoid()
    }
    
    public static var productSemigroup : UInt32ProductSemigroup {
        return UInt32ProductSemigroup()
    }
    
    public static var productMonoid : UInt32ProductMonoid {
        return UInt32ProductMonoid()
    }
    
    public static var eq : UInt32Eq {
        return UInt32Eq()
    }
    
    public static var order : UInt32Order {
        return UInt32Order()
    }
}

// Int64

public class UInt64SumSemigroup : Semigroup {
    public typealias A = UInt64
    
    public func combine(_ a : UInt64, _ b : UInt64) -> UInt64 {
        return a.addingReportingOverflow(b).partialValue
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
        return a.multipliedReportingOverflow(by: b).partialValue
    }
}

public class UInt64ProductMonoid : UInt64ProductSemigroup, Monoid {
    public var empty : UInt64 {
        return 1
    }
}

public class UInt64Eq : Eq {
    public typealias A = UInt64
    
    public func eqv(_ a: UInt64, _ b: UInt64) -> Bool {
        return a == b
    }
}

public class UInt64Order : UInt64Eq, Order {
    public func compare(_ a: UInt64, _ b: UInt64) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension UInt64 {
    public static var sumSemigroup : UInt64SumSemigroup {
        return UInt64SumSemigroup()
    }
    
    public static var sumMonoid : UInt64SumMonoid {
        return UInt64SumMonoid()
    }
    
    public static var productSemigroup : UInt64ProductSemigroup {
        return UInt64ProductSemigroup()
    }
    
    public static var productMonoid : UInt64ProductMonoid {
        return UInt64ProductMonoid()
    }
    
    public static var eq : UInt64Eq {
        return UInt64Eq()
    }
    
    public static var order : UInt64Order {
        return UInt64Order()
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

public class FloatEq : Eq {
    public typealias A = Float
    
    public func eqv(_ a: Float, _ b: Float) -> Bool {
        return a.isEqual(to: b)
    }
}

public class FloatOrder : FloatEq, Order {
    public func compare(_ a: Float, _ b: Float) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension Float {
    public static var sumSemigroup : FloatSumSemigroup {
        return FloatSumSemigroup()
    }
    
    public static var sumMonoid : FloatSumMonoid {
        return FloatSumMonoid()
    }
    
    public static var productSemigroup : FloatProductSemigroup {
        return FloatProductSemigroup()
    }
    
    public static var productMonoid : FloatProductMonoid {
        return FloatProductMonoid()
    }
    
    public static var eq : FloatEq {
        return FloatEq()
    }
    
    public static var order : FloatOrder {
        return FloatOrder()
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

public class DoubleEq : Eq {
    public typealias A = Double
    
    public func eqv(_ a: Double, _ b: Double) -> Bool {
        return a.isEqual(to: b)
    }
}

public class DoubleOrder : DoubleEq, Order {
    public func compare(_ a: Double, _ b: Double) -> Int {
        if a < b {
            return -1
        } else if a > b {
            return 1
        }
        return 0
    }
}

public extension Double {
    public static var sumSemigroup : DoubleSumSemigroup {
        return DoubleSumSemigroup()
    }
    
    public static var sumMonoid : DoubleSumMonoid {
        return DoubleSumMonoid()
    }
    
    public static var productSemigroup : DoubleProductSemigroup {
        return DoubleProductSemigroup()
    }
    
    public static var productMonoid : DoubleProductMonoid {
        return DoubleProductMonoid()
    }
    
    public static var eq : DoubleEq {
        return DoubleEq()
    }
    
    public static var order : DoubleOrder {
        return DoubleOrder()
    }
}
